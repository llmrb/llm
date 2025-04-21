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
  #   res = llm.files.create file: LLM::File("/documents/haiku.txt")
  class Files
    ##
    # Returns a new Responses object
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
    # @raise (see LLM::HTTPClient#request)
    # @return [OpenStruct]
    def all(**params)
      req = Net::HTTP::Get.new("/v1/files?#{URI.encode_www_form(params)}", headers)
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
    # @raise (see LLM::HTTPClient#request)
    # @return [OpenStruct]
    def create(file:, purpose: "user_data", **params)
      multi = LLM::Multipart.new(params.merge!(file:, purpose:))
      req = Net::HTTP::Post.new("/v1/files", headers)
      req["content-type"] = multi.content_type
      req.body = multi.body
      res = request(http, req)
      LLM::Response::File.new(res)
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
