# frozen_string_literal: true

class LLM::Ollama
  ##
  # The {LLM::Ollama::Models LLM::Ollama::Models} class provides a model
  # object for interacting with [Ollama's models API](https://github.com/ollama/ollama/blob/main/docs/api.md#list-local-models).
  # The models API allows a client to query Ollama for a list of models
  # that are available for use with the Ollama API.
  #
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.ollama(nil)
  #   res = llm.models.all
  #   res.each do |model|
  #     print "id: ", model.id, "\n"
  #   end
  class Models
    include LLM::Utils

    ##
    # Returns a new Models object
    # @param provider [LLM::Provider]
    # @return [LLM::Ollama::Models]
    def initialize(provider)
      @provider = provider
    end

    ##
    # List all models
    # @example
    #   llm = LLM.ollama(nil)
    #   res = llm.models.all
    #   res.each do |model|
    #     print "id: ", model.id, "\n"
    #   end
    # @see https://github.com/ollama/ollama/blob/main/docs/api.md#list-local-models Ollama docs
    # @see https://ollama.com/library Ollama library
    # @param [Hash] params Other parameters (see Ollama docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response::ModelList]
    def all(**params)
      query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new("/api/tags?#{query}", headers)
      res = execute(client: http, request: req)
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

    [:headers, :execute].each do |m|
      define_method(m) { |*args, **kwargs, &b| @provider.send(m, *args, **kwargs, &b) }
    end
  end
end
