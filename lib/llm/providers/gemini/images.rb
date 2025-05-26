# frozen_string_literal: true

class LLM::Gemini
  ##
  # The {LLM::Gemini::Images LLM::Gemini::Images} class provides an images
  # object for interacting with [Gemini's images API](https://ai.google.dev/gemini-api/docs/image-generation).
  # Please note that unlike OpenAI, which can return either URLs or base64-encoded strings,
  # Gemini's images API will always return an image as a base64 encoded string that
  # can be decoded into binary.
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.gemini(ENV["KEY"])
  #   res = llm.images.create prompt: "A dog on a rocket to the moon"
  #   IO.copy_stream res.images[0], "rocket.png"
  class Images
    include Format

    ##
    # Returns a new Images object
    # @param provider [LLM::Provider]
    # @return [LLM::Gemini::Responses]
    def initialize(provider)
      @provider = provider
    end

    ##
    # Create an image
    # @example
    #   llm = LLM.gemini(ENV["KEY"])
    #   res = llm.images.create prompt: "A dog on a rocket to the moon"
    #   IO.copy_stream res.images[0], "rocket.png"
    # @see https://ai.google.dev/gemini-api/docs/image-generation Gemini docs
    # @param [String] prompt The prompt
    # @param [Hash] params Other parameters (see Gemini docs)
    # @raise (see LLM::Provider#request)
    # @note
    #  The prompt should make it clear you want to generate an image, or you
    #  might unexpectedly receive a purely textual response. This is due to how
    #  Gemini implements image generation under the hood.
    # @return [LLM::Response::Image]
    def create(prompt:, model: "gemini-2.0-flash-exp-image-generation", **params)
      req  = Net::HTTP::Post.new("/v1beta/models/#{model}:generateContent?key=#{key}", headers)
      body = JSON.dump({
        contents: [{parts: {text: prompt}}],
        generationConfig: {responseModalities: ["TEXT", "IMAGE"]}
      }.merge!(params))
      req.body = body
      res = execute(client: http, request: req)
      LLM::Response::Image.new(res).extend(response_parser)
    end

    ##
    # Edit an image
    # @example
    #   llm = LLM.gemini(ENV["KEY"])
    #   res = llm.images.edit image: LLM::File("cat.png"), prompt: "Add a hat to the cat"
    #   IO.copy_stream res.images[0], "hatoncat.png"
    # @see https://ai.google.dev/gemini-api/docs/image-generation Gemini docs
    # @param [String, LLM::File] image The image to edit
    # @param [String] prompt The prompt
    # @param [Hash] params Other parameters (see Gemini docs)
    # @raise (see LLM::Provider#request)
    # @note (see LLM::Gemini::Images#create)
    # @return [LLM::Response::Image]
    def edit(image:, prompt:, model: "gemini-2.0-flash-exp-image-generation", **params)
      req   = Net::HTTP::Post.new("/v1beta/models/#{model}:generateContent?key=#{key}", headers)
      image = LLM.File(image)
      body  = JSON.dump({
        contents: [{parts: [{text: prompt}, format.format_content(image)]}],
        generationConfig: {responseModalities: ["TEXT", "IMAGE"]}
      }.merge!(params)).b
      set_body_stream(req, StringIO.new(body))
      res = execute(client: http, request: req)
      LLM::Response::Image.new(res).extend(response_parser)
    end

    ##
    # @raise [NotImplementedError]
    #  This method is not implemented by Gemini
    def create_variation
      raise NotImplementedError
    end

    private

    def format
      @format ||= CompletionFormat.new(nil)
    end

    def key
      @provider.instance_variable_get(:@key)
    end

    def http
      @provider.instance_variable_get(:@http)
    end

    [:response_parser, :headers, :execute, :set_body_stream].each do |m|
      define_method(m) { |*args, **kwargs, &b| @provider.send(m, *args, **kwargs, &b) }
    end
  end
end
