# frozen_string_literal: true

class LLM::XAI
  ##
  # The {LLM::XAI::Images LLM::XAI::Images} class provides an interface
  # for [xAI's images API](https://docs.x.ai/docs/guides/image-generations).
  # xAI supports multiple response formats: temporary URLs, or binary strings
  # encoded in base64. The default is to return temporary URLs.
  #
  # @example Temporary URLs
  #   #!/usr/bin/env ruby
  #   require "llm"
  #   require "open-uri"
  #   require "fileutils"
  #
  #   llm = LLM.xai(key: ENV["KEY"])
  #   res = llm.images.create prompt: "A dog on a rocket to the moon"
  #   FileUtils.mv OpenURI.open_uri(res.urls[0]).path,
  #                "rocket.png"
  #
  # @example Binary strings
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.xai(key: ENV["KEY"])
  #   res = llm.images.create prompt: "A dog on a rocket to the moon",
  #                           response_format: "b64_json"
  #   IO.copy_stream res.images[0], "rocket.png"
  class Images < LLM::OpenAI::Images
    ##
    # Create an image
    # @example
    #   llm = LLM.xai(key: ENV["KEY"])
    #   res = llm.images.create prompt: "A dog on a rocket to the moon"
    #   res.urls.each { print _1, "\n"}
    # @see https://docs.x.ai/docs/guides/image-generations xAI docs
    # @param [String] prompt The prompt
    # @param [String] model The model to use
    # @param [Hash] params Other parameters (see xAI docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response]
    def create(prompt:, model: "grok-2-image-1212", **params)
      super
    end

    ##
    # @raise [NotImplementedError]
    def edit(model: "grok-2-image-1212", **)
      raise NotImplementedError
    end

    ##
    # @raise [NotImplementedError]
    def create_variation(model: "grok-2-image-1212", **)
      raise NotImplementedError
    end
  end
end
