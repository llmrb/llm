# frozen_string_literal: true

class LLM::Anthropic
  ##
  # The {LLM::Anthropic::Files LLM::Anthropic::Files} class provides a files
  # object for interacting with [Anthropic's Files API](https://docs.anthropic.com/en/docs/build-with-claude/files).
  #
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.anthropic(key: ENV["KEY"])
  #   bot = LLM::Bot.new(llm)
  #   file = llm.files.create file: "/books/goodread.pdf"
  #   bot.chat ["Tell me about this PDF", file]
  #   bot.messages.select(&:assistant?).each { print "[#{_1.role}]", _1.content, "\n" }
  class Files
    require_relative "response/file"
    ##
    # Returns a new Files object
    # @param provider [LLM::Provider]
    # @return [LLM::Anthropic::Files]
    def initialize(provider)
      @provider = provider
    end

    ##
    # List all files
    # @example
    #   llm = LLM.anthropic(key: ENV["KEY"])
    #   res = llm.files.all
    #   res.each do |file|
    #     print "id: ", file.id, "\n"
    #   end
    # @see https://docs.anthropic.com/en/docs/build-with-claude/files Anthropic docs
    # @param [Hash] params Other parameters (see Anthropic docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response]
    def all(**params)
      query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new("/v1/files?#{query}", headers)
      res = execute(request: req)
      LLM::Response.new(res).extend(LLM::Anthropic::Response::Enumerable)
    end

    ##
    # Create a file
    # @example
    #   llm = LLM.anthropic(key: ENV["KEY"])
    #   res = llm.files.create file: "/documents/haiku.txt"
    # @see https://docs.anthropic.com/en/docs/build-with-claude/files Anthropic docs
    # @param [File, LLM::File, String] file The file
    # @param [Hash] params Other parameters (see Anthropic docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response]
    def create(file:, **params)
      multi = LLM::Multipart.new(params.merge!(file: LLM.File(file)))
      req = Net::HTTP::Post.new("/v1/files", headers)
      req["content-type"] = multi.content_type
      set_body_stream(req, multi.body)
      res = execute(request: req)
      LLM::Response.new(res).extend(LLM::Anthropic::Response::File)
    end

    ##
    # Get a file
    # @example
    #   llm = LLM.anthropic(key: ENV["KEY"])
    #   res = llm.files.get(file: "file-1234567890")
    #   print "id: ", res.id, "\n"
    # @see https://docs.anthropic.com/en/docs/build-with-claude/files Anthropic docs
    # @param [#id, #to_s] file The file ID
    # @param [Hash] params Other parameters - if any (see Anthropic docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response]
    def get(file:, **params)
      file_id = file.respond_to?(:id) ? file.id : file
      query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new("/v1/files/#{file_id}?#{query}", headers)
      res = execute(request: req)
      LLM::Response.new(res).extend(LLM::Anthropic::Response::File)
    end

    ##
    # Delete a file
    # @example
    #   llm = LLM.anthropic(key: ENV["KEY"])
    #   res = llm.files.delete(file: "file-1234567890")
    #   print res.deleted, "\n"
    # @see https://docs.anthropic.com/en/docs/build-with-claude/files Anthropic docs
    # @param [#id, #to_s] file The file ID
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response]
    def delete(file:)
      file_id = file.respond_to?(:id) ? file.id : file
      req = Net::HTTP::Delete.new("/v1/files/#{file_id}", headers)
      res = execute(request: req)
      LLM::Response.new(res)
    end

    ##
    # @raise [NotImplementedError]
    def download(file:, **params)
      raise NotImplementedError, "This feature is not yet implemented by llm.rb"
    end

    ##
    # @raise [NotImplementedError]
    def get_metadata(file:)
      raise NotImplementedError, "This feature is not yet implemented by llm.rb"
    end
    alias_method :retrieve_metadata, :get_metadata

    private

    def key
      @provider.instance_variable_get(:@key)
    end

    [:headers, :execute, :set_body_stream].each do |m|
      define_method(m) { |*args, **kwargs, &b| @provider.send(m, *args, **kwargs, &b) }
    end
  end
end
