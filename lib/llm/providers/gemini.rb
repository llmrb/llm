# frozen_string_literal: true

module LLM
  ##
  # The Gemini class implements a provider for
  # [Gemini](https://ai.google.dev/).
  #
  # The Gemini provider can accept multiple inputs (text, images,
  # audio, and video). The inputs can be provided inline via the
  # prompt for files under 20MB or via the Gemini Files API for
  # files that are over 20MB
  #
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.gemini(ENV["KEY"])
  #   conversation = LLM::Conversation.new(llm).lazy
  #   conversation.chat LLM::File("/images/capybara.png")
  #   conversation.chat "Describe the image"
  #   message = conversation.last_message
  #   print "[#{message.role}]", message.content, "\n"
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm  = LLM.gemini(ENV["KEY"])
  #   chat = LLM::Conversation.new(llm).lazy
  #   chat.chat ["Describe the image", LLM::File("/images/capybara.png")]
  #   message = conversation.last_message
  #   print "[#{message.role}]", message.content, "\n"
  class Gemini < Provider
    require_relative "gemini/error_handler"
    require_relative "gemini/response_parser"
    require_relative "gemini/format"
    require_relative "gemini/images"
    require_relative "gemini/files"
    require_relative "gemini/audio"
    include Format

    HOST = "generativelanguage.googleapis.com"

    ##
    # @param secret (see LLM::Provider#initialize)
    def initialize(secret, **)
      super(secret, host: HOST, **)
    end

    ##
    # Provides an embedding
    # @param input (see LLM::Provider#embed)
    # @param model (see LLM::Provider#embed)
    # @param params (see LLM::Provider#embed)
    # @raise (see LLM::HTTPClient#request)
    # @return (see LLM::Provider#embed)
    def embed(input, model: "text-embedding-004", **params)
      path = ["/v1beta/models/#{model}", "embedContent?key=#{@secret}"].join(":")
      req = Net::HTTP::Post.new(path, headers)
      req.body = JSON.dump({content: {parts: [{text: input}]}})
      res = request(@http, req)
      Response::Embedding.new(res).extend(response_parser)
    end

    ##
    # Provides an interface to the chat completions API
    # @see https://ai.google.dev/api/generate-content#v1beta.models.generateContent Gemini docs
    # @param prompt (see LLM::Provider#complete)
    # @param role (see LLM::Provider#complete)
    # @param model (see LLM::Provider#complete)
    # @param params (see LLM::Provider#complete)
    # @example (see LLM::Provider#complete)
    # @raise (see LLM::HTTPClient#request)
    # @return (see LLM::Provider#complete)
    def complete(prompt, role = :user, model: "gemini-1.5-flash", **params)
      path     = ["/v1beta/models/#{model}", "generateContent?key=#{@secret}"].join(":")
      req      = Net::HTTP::Post.new(path, headers)
      messages = [*(params.delete(:messages) || []), LLM::Message.new(role, prompt)]
      req.body = JSON.dump({contents: format(messages)})
      res      = request(@http, req)
      Response::Completion.new(res).extend(response_parser)
    end

    ##
    # Provides an interface to Gemini's audio API
    # @see https://ai.google.dev/gemini-api/docs/audio Gemini docs
    def audio
      LLM::Gemini::Audio.new(self)
    end

    ##
    # Provides an interface to Gemini's image generation API
    # @see https://ai.google.dev/gemini-api/docs/image-generation Gemini docs
    # @return [see LLM::Gemini::Images]
    def images
      LLM::Gemini::Images.new(self)
    end

    ##
    # Provides an interface to Gemini's file management API
    # @see https://ai.google.dev/gemini-api/docs/files Gemini docs
    def files
      LLM::Gemini::Files.new(self)
    end

    ##
    # @return (see LLM::Provider#assistant_role)
    def assistant_role
      "model"
    end

    ##
    # @return (see LLM::Provider#models)
    def models
      @models ||= load_models!("gemini")
    end

    private

    def headers
      {
        "Content-Type" => "application/json"
      }
    end

    def response_parser
      LLM::Gemini::ResponseParser
    end

    def error_handler
      LLM::Gemini::ErrorHandler
    end
  end
end
