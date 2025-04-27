# frozen_string_literal: true

class LLM::Gemini
  ##
  # The {LLM::Gemini::Models LLM::Gemini::Models} class provides a model
  # object for interacting with [Gemini's models API](https://ai.google.dev/api/models?hl=en#method:-models.list).
  # The models API allows a client to query Gemini for a list of models
  # that are available for use with the Gemini API.
  #
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.gemini(ENV["KEY"])
  #   res = llm.models.all
  #   res.each do |model|
  #     print "id: ", model.id, "\n"
  #   end
  class Models
    include LLM::Utils

    ##
    # Returns a new Models object
    # @param provider [LLM::Provider]
    # @return [LLM::Gemini::Models]
    def initialize(provider)
      @provider = provider
    end

    ##
    # List all models
    # @example
    #   llm = LLM.gemini(ENV["KEY"])
    #   res = llm.models.all
    #   res.each do |model|
    #     print "id: ", model.id, "\n"
    #   end
    # @see https://ai.google.dev/api/models?hl=en#method:-models.list Gemini docs
    # @param [Hash] params Other parameters (see Gemini docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response::ModelList]
    def all(**params)
      query = URI.encode_www_form(params.merge!(key: secret))
      req = Net::HTTP::Get.new("/v1beta/models?#{query}", headers)
      res = request(http, req)
      LLM::Response::ModelList.new(res).tap { |modellist|
        models = modellist.body["models"].map do |model|
          model = model.transform_keys { snakecase(_1) }
          LLM::Model.from_hash(model).tap { _1.provider = @provider }
        end
        modellist.models = models
      }
    end

    private

    def http
      @provider.instance_variable_get(:@http)
    end

    def secret
      @provider.instance_variable_get(:@secret)
    end

    [:headers, :request].each do |m|
      define_method(m) { |*args, &b| @provider.send(m, *args, &b) }
    end
  end
end
