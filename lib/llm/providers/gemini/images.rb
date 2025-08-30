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
  #   llm = LLM.gemini(key: ENV["KEY"])
  #   res = llm.images.create prompt: "A dog on a rocket to the moon"
  #   IO.copy_stream res.images[0], "rocket.png"
  class Images
    require_relative "response/image"
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
    #   llm = LLM.gemini(key: ENV["KEY"])
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
    # @return [LLM::Response]
    def create(prompt:, model: "gemini-2.0-flash-exp-image-generation", **params)
      req  = Net::HTTP::Post.new("/v1beta/models/#{model}:generateContent?key=#{key}", headers)
      body = JSON.dump({
        contents: [{parts: [{text: create_prompt}, {text: prompt}]}],
        generationConfig: {responseModalities: ["TEXT", "IMAGE"]}
      }.merge!(params))
      req.body = body
      res = execute(request: req)
      LLM::Response.new(res).extend(LLM::Gemini::Response::Image)
    end

    ##
    # Edit an image
    # @example
    #   llm = LLM.gemini(key: ENV["KEY"])
    #   res = llm.images.edit image: "cat.png", prompt: "Add a hat to the cat"
    #   IO.copy_stream res.images[0], "hatoncat.png"
    # @see https://ai.google.dev/gemini-api/docs/image-generation Gemini docs
    # @param [String, LLM::File] image The image to edit
    # @param [String] prompt The prompt
    # @param [Hash] params Other parameters (see Gemini docs)
    # @raise (see LLM::Provider#request)
    # @note (see LLM::Gemini::Images#create)
    # @return [LLM::Response]
    def edit(image:, prompt:, model: "gemini-2.0-flash-exp-image-generation", **params)
      req   = Net::HTTP::Post.new("/v1beta/models/#{model}:generateContent?key=#{key}", headers)
      image = LLM.File(image)
      body  = JSON.dump({
        contents: [{parts: [{text: edit_prompt}, {text: prompt}, format.format_content(image)]}],
        generationConfig: {responseModalities: ["TEXT", "IMAGE"]}
      }.merge!(params)).b
      set_body_stream(req, StringIO.new(body))
      res = execute(request: req)
      LLM::Response.new(res).extend(LLM::Gemini::Response::Image)
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

    def create_prompt
      <<~PROMPT
        ## Context
        Your task is to generate one or more image(s) based on the user's instructions.
        The user will provide you with text only.

        ## Instructions
        1. The model *MUST* generate image(s) based on the user text alone.
        2. The model *MUST NOT* generate anything else.
      PROMPT
    end

    def edit_prompt
      <<~PROMPT
        ## Context
        Your task is to edit the provided image based on the user's instructions.
        The user will provide you with both text and an image.

        ## Instructions
        1. The model *MUST* edit the provided image based on the user's instructions
        2. The model *MUST NOT* generate a new image.
        3. The model *MUST NOT* generate anything else.
      PROMPT
    end

    [:headers, :execute, :set_body_stream].each do |m|
      define_method(m) { |*args, **kwargs, &b| @provider.send(m, *args, **kwargs, &b) }
    end
  end
end
