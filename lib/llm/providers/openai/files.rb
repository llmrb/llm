# frozen_string_literal: true

class LLM::OpenAI
  ##
  # The {LLM::OpenAI::Files LLM::OpenAI::Files} class provides a files
  # object for interacting with [OpenAI's Files API](https://platform.openai.com/docs/api-reference/files/create).
  # The files API allows a client to upload files for use with OpenAI's models
  # and API endpoints. OpenAI supports multiple file formats, including text
  # files, CSV files, JSON files, and more.
  #
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.openai(ENV["KEY"])
  #   bot = LLM::Chat.new(llm).lazy
  #   file = llm.files.create file: LLM::File("/documents/freebsd.pdf")
  #   bot.chat(file)
  #   bot.chat("Describe the document")
  #   bot.messages.select(&:assistant?).each { print "[#{_1.role}]", _1.content, "\n" }
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.openai(ENV["KEY"])
  #   bot = LLM::Chat.new(llm).lazy
  #   file = llm.files.create file: LLM::File("/documents/openbsd.pdf")
  #   bot.chat(["Describe the document I sent to you", file])
  #   bot.messages.select(&:assistant?).each { print "[#{_1.role}]", _1.content, "\n" }
  class Files
    ##
    # Returns a new Files object
    # @param provider [LLM::Provider]
    # @return [LLM::OpenAI::Files]
    def initialize(provider)
      @provider = provider
    end

    ##
    # List all files
    # @example
    #   llm = LLM.openai(ENV["KEY"])
    #   res = llm.files.all
    #   res.each do |file|
    #     print "id: ", file.id, "\n"
    #   end
    # @see https://platform.openai.com/docs/api-reference/files/list OpenAI docs
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response::FileList]
    def all(**params)
      query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new("/v1/files?#{query}", headers)
      res = request(http, req)
      LLM::Response::FileList.new(res).tap { |filelist|
        files = filelist.body["data"].map { OpenStruct.from_hash(_1) }
        filelist.files = files
      }
    end

    ##
    # Create a file
    # @example
    #   llm = LLM.openai(ENV["KEY"])
    #   res = llm.files.create file: LLM::File("/documents/haiku.txt"),
    # @see https://platform.openai.com/docs/api-reference/files/create OpenAI docs
    # @param [File] file The file
    # @param [String] purpose The purpose of the file (see OpenAI docs)
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response::File]
    def create(file:, purpose: "assistants", **params)
      multi = LLM::Multipart.new(params.merge!(file:, purpose:))
      req = Net::HTTP::Post.new("/v1/files", headers)
      req["content-type"] = multi.content_type
      req.body_stream = multi.body
      res = request(http, req)
      LLM::Response::File.new(res)
    end

    ##
    # Get a file
    # @example
    #   llm = LLM.openai(ENV["KEY"])
    #   res = llm.files.get(file: "file-1234567890")
    #   print "id: ", res.id, "\n"
    # @see https://platform.openai.com/docs/api-reference/files/get OpenAI docs
    # @param [#id, #to_s] file The file ID
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response::File]
    def get(file:, **params)
      file_id = file.respond_to?(:id) ? file.id : file
      query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new("/v1/files/#{file_id}?#{query}", headers)
      res = request(http, req)
      LLM::Response::File.new(res)
    end

    ##
    # Download the content of a file
    # @example
    #   llm = LLM.openai(ENV["KEY"])
    #   res = llm.files.download(file: "file-1234567890")
    #   File.binwrite "haiku1.txt", res.file.read
    #   print res.file.read, "\n"
    # @see https://platform.openai.com/docs/api-reference/files/content OpenAI docs
    # @param [#id, #to_s] file The file ID
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response::DownloadFile]
    def download(file:, **params)
      query = URI.encode_www_form(params)
      file_id = file.respond_to?(:id) ? file.id : file
      req = Net::HTTP::Get.new("/v1/files/#{file_id}/content?#{query}", headers)
      io = StringIO.new("".b)
      res = request(http, req) { |res| res.read_body { |chunk| io << chunk } }
      LLM::Response::DownloadFile.new(res).tap { _1.file = io }
    end

    ##
    # Delete a file
    # @example
    #   llm = LLM.openai(ENV["KEY"])
    #   res = llm.files.delete(file: "file-1234567890")
    #   print res.deleted, "\n"
    # @see https://platform.openai.com/docs/api-reference/files/delete OpenAI docs
    # @param [#id, #to_s] file The file ID
    # @raise (see LLM::Provider#request)
    # @return [OpenStruct] Response body
    def delete(file:)
      file_id = file.respond_to?(:id) ? file.id : file
      req = Net::HTTP::Delete.new("/v1/files/#{file_id}", headers)
      res = request(http, req)
      OpenStruct.from_hash JSON.parse(res.body)
    end

    private

    def http
      @provider.instance_variable_get(:@http)
    end

    [:headers, :request].each do |m|
      define_method(m) { |*args, &b| @provider.send(m, *args, &b) }
    end
  end
end
