# frozen_string_literal: true

class LLM::OpenAI
  ##
  # The {LLM::OpenAI::Models LLM::OpenAI::Models} class provides a model
  # object for interacting with [OpenAI's models API](https://platform.openai.com/docs/api-reference/models/list).
  # The models API allows a client to query OpenAI for a list of models
  # that are available for use with the OpenAI API.
  #
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.openai(ENV["KEY"])
  #   res = llm.models.all
  #   res.each do |model|
  #     print "id: ", model.id, "\n"
  #   end
  class Models
    ##
    # Returns a new Models object
    # @param provider [LLM::Provider]
    # @return [LLM::OpenAI::Files]
    def initialize(provider)
      @provider = provider
    end

    ##
    # List all models
    # @example
    #   llm = LLM.openai(ENV["KEY"])
    #   res = llm.models.all
    #   res.each do |model|
    #     print "id: ", model.id, "\n"
    #   end
    # @see https://platform.openai.com/docs/api-reference/models/list OpenAI docs
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response::FileList]
    def all(**params)
      query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new("/v1/models?#{query}", headers)
      res = execute(request: req)
      LLM::Response::ModelList.new(res).tap { |modellist|
        models = modellist.body["data"].map do |model|
          LLM::Model.from_hash(model).tap { _1.provider = @provider }
        end
        modellist.models = models
      }
    end

    private

    [:headers, :execute, :set_body_stream].each do |m|
      define_method(m) { |*args, **kwargs, &b| @provider.send(m, *args, **kwargs, &b) }
    end
  end
end
