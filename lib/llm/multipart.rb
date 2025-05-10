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
  # Returns the multipart request body
  # @return [String]
  def body
    io = StringIO.new("".b)
    [*parts, StringIO.new("--#{@boundary}--\r\n".b)].each { IO.copy_stream(_1.tap(&:rewind), io) }
    io.tap(&:rewind)
  end

  private

  attr_reader :params

  def file(key, file, locals)
    locals = locals.merge(attributes(file))
    build_file(locals) do |body|
      IO.copy_stream(file.path, body)
      body << "\r\n"
    end
  end

  def form(key, value, locals)
    locals = locals.merge(value:)
    build_form(locals) do |body|
      body << value.to_s
      body << "\r\n"
    end
  end

  def build_file(locals)
    StringIO.new("".b).tap do |io|
      io << "--#{locals[:boundary]}" \
             "\r\n" \
             "Content-Disposition: form-data; name=\"#{locals[:key]}\";" \
             "filename=\"#{locals[:filename]}\"" \
             "\r\n" \
             "Content-Type: #{locals[:content_type]}" \
             "\r\n\r\n"
      yield(io)
    end
  end

  def build_form(locals)
    StringIO.new("".b).tap do |io|
      io << "--#{locals[:boundary]}" \
             "\r\n" \
             "Content-Disposition: form-data; name=\"#{locals[:key]}\"" \
             "\r\n\r\n"
      yield(io)
    end
  end

  ##
  # Returns the multipart request body parts
  # @return [Array<String>]
  def parts
    params.map do |key, value|
      locals = {key: key.to_s.b, boundary: boundary.to_s.b}
      if value.respond_to?(:path)
        file(key, value, locals)
      else
        form(key, value, locals)
      end
    end
  end

  def attributes(file)
    {
      filename: File.basename(file.path).b,
      content_type: LLM::Mime[file].b
    }
  end
end
