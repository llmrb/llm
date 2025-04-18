# frozen_string_literal: true

class LLM::OpenAI
  ##
  # The {LLM::OpenAI::Images LLM::OpenAI::Images} class provides an images
  # object for interacting with [OpenAI's images API](https://platform.openai.com/docs/api-reference/images).
  # @example
  #   llm = LLM.openai(ENV["KEY"])
  #   res = llm.images.create prompt: "A dog on a rocket to the moon"
  #   p res.data.urls
  class Images
    ##
    # Returns a new Responses object
    # @param provider [LLM::Provider]
    # @return [LLM::OpenAI::Responses]
    def initialize(provider)
      @provider = provider
    end

    ##
    # Create an image
    # @example
    #   llm = LLM.openai(ENV["KEY"])
    #   res = llm.images.create prompt: "A dog on a rocket to the moon"
    #   p res.data.urls
    # @see https://platform.openai.com/docs/api-reference/images/create OpenAI docs
    # @param [String] prompt The prompt
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::HTTPClient#request)
    # @return [OpenStruct]
    def create(prompt:, **params)
      req = Net::HTTP::Post.new("/v1/images/generations", headers)
      req.body = JSON.dump({prompt:, n: 1}.merge!(params))
      res = request(http, req)
      OpenStruct.from_hash JSON.parse(res.body)
    end

    ##
    # Create image variations
    # @example
    #   llm = LLM.openai(ENV["KEY"])
    #   res = llm.images.create_variation(image: LLM::File("/images/hat.png"), n: 5)
    #   p res.data.urls
    # @see https://platform.openai.com/docs/api-reference/images/createVariation OpenAI docs
    # @param [File] image The image to create variations from
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::HTTPClient#request)
    # @return [OpenStruct]
    def create_variation(image:, **params)
      multi = LLM::Multipart.new(params.merge!(image:))
      req = Net::HTTP::Post.new("/v1/images/variations", headers)
      req["content-type"] = multi.content_type
      req.body = multi.body
      res = request(http, req)
      OpenStruct.from_hash JSON.parse(res.body)
    end

    ##
    # Edit an image
    # @example
    #   llm = LLM.openai(ENV["KEY"])
    #   res = llm.images.edit(image: LLM::File("/images/hat.png"), prompt: "A cat wearing this hat")
    #   p res.data.urls
    # @see https://platform.openai.com/docs/api-reference/images/createEdit OpenAI docs
    # @param [File] image The image to edit
    # @param [String] prompt The prompt
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::HTTPClient#request)
    # @return [OpenStruct]
    def edit(image:, prompt:, **params)
      multi = LLM::Multipart.new(params.merge!(image:, prompt:))
      req = Net::HTTP::Post.new("/v1/images/edits", headers)
      req["content-type"] = multi.content_type
      req.body = multi.body
      res = request(http, req)
      OpenStruct.from_hash JSON.parse(res.body)
    end

    private

    def http
      @provider.instance_variable_get(:@http)
    end

    [:response_parser, :headers, :request].each do |m|
      define_method(m) { |*args, &b| @provider.send(m, *args, &b) }
    end
  end
end
