# encoding: ascii-8bit
# frozen_string_literal: true

##
# @private
class LLM::Multipart
  require "llm"
  require "securerandom"

  ##
  # @return [String]
  attr_reader :boundary

  ##
  # @param [Hash] params
  #  Request parameters
  # @return [LLM::Multipart]
  def initialize(params)
    @boundary = "BOUNDARY__#{SecureRandom.hex(16)}"
    @params = params
  end

  ##
  # Returns the multipart content type
  # @return [String]
  def content_type
    "multipart/form-data; boundary=#{@boundary}"
  end

  ##
  # Returns the multipart request body parts
  # @return [Array<String>]
  def parts
    params.map do |key, value|
      locals = {key: key.to_s.b, boundary: boundary.to_s.b}
      if value.respond_to?(:path)
        file_part(key, value, locals)
      else
        data_part(key, value, locals)
      end
    end
  end

  ##
  # Returns the multipart request body
  # @return [String]
  def body
    [*parts, "--#{@boundary}--\r\n"].inject(&:<<)
  end

  private

  attr_reader :params

  def attributes(file)
    {
      filename: File.basename(file.path).b,
      content_type: LLM::Mime[file].b
    }
  end

  def multipart_header(type:, locals:)
    if type == :file
      str = "".b
      str << "--#{locals[:boundary]}" \
             "\r\n" \
             "Content-Disposition: form-data; name=\"#{locals[:key]}\";" \
             "filename=\"#{locals[:filename]}\"" \
             "\r\n" \
             "Content-Type: #{locals[:content_type]}" \
             "\r\n\r\n"
    elsif type == :data
      str = "".b
      str << "--#{locals[:boundary]}" \
             "\r\n" \
             "Content-Disposition: form-data; name=\"#{locals[:key]}\"" \
             "\r\n\r\n"
    else
      raise "unknown type: #{type}"
    end
  end

  def file_part(key, file, locals)
    locals = locals.merge(attributes(file))
    multipart_header(type: :file, locals:).tap do
      _1 << File.binread(file.path)
      _1 << "\r\n"
    end
  end

  def data_part(key, value, locals)
    locals = locals.merge(value:)
    multipart_header(type: :data, locals:).tap do
      _1 << value
      _1 << "\r\n"
    end
  end
end
