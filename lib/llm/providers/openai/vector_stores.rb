# frozen_string_literal: true

class LLM::OpenAI
  ##
  # The {LLM::OpenAI::VectorStore LLM::OpenAI::VectorStore} class provides
  # an interface to OpenAI's vector stores API
  # @see https://platform.openai.com/docs/api-reference/vector_stores/create OpenAI docs
  class VectorStores
    ##
    # @param [LLM::Provider] provider
    #  An OpenAI provider
    def initialize(provider)
      @provider = provider
    end

    ##
    # List all vector stores
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @return [LLM::Response]
    def all(**params)
      query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new("/v1/vector_stores?#{query}", headers)
      res = execute(request: req)
      LLM::Response.new(res)
    end

    ##
    # Create a vector store
    # @param [String] name The name of the vector store
    # @param [Array<String>] file_ids The IDs of the files to include in the vector store
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response]
    # @see https://platform.openai.com/docs/api-reference/vector_stores/create OpenAI docs
    def create(name:, file_ids: [], **params)
      req = Net::HTTP::Post.new("/v1/vector_stores", headers)
      req.body = JSON.dump(params.merge({name:, file_ids:}).compact)
      res = execute(request: req)
      LLM::Response.new(res)
    end

    ##
    # Get a vector store
    # @param [String, #id] vector The ID of the vector store
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response]
    # @see https://platform.openai.com/docs/api-reference/vector_stores/retrieve OpenAI docs
    def get(vector:)
      vector_id = vector.respond_to?(:id) ? vector.id : vector
      req = Net::HTTP::Get.new("/v1/vector_stores/#{vector_id}", headers)
      res = execute(request: req)
      LLM::Response.new(res)
    end

    ##
    # Modify an existing vector store
    # @param [String, #id] vector The ID of the vector store
    # @param [String] name The new name of the vector store
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response]
    # @see https://platform.openai.com/docs/api-reference/vector_stores/modify OpenAI docs
    def modify(vector:, name: nil, **params)
      vector_id = vector.respond_to?(:id) ? vector.id : vector
      req = Net::HTTP::Post.new("/v1/vector_stores/#{vector_id}", headers)
      req.body = JSON.dump(params.merge({name:}).compact)
      res = execute(request: req)
      LLM::Response.new(res)
    end

    ##
    # Delete a vector store
    # @param [String, #id] vector The ID of the vector store
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response]
    # @see https://platform.openai.com/docs/api-reference/vector_stores/delete OpenAI docs
    def delete(vector:)
      vector_id = vector.respond_to?(:id) ? vector.id : vector
      req = Net::HTTP::Delete.new("/v1/vector_stores/#{vector_id}", headers)
      res = execute(request: req)
      LLM::Response.new(res)
    end

    ##
    # Search a vector store
    # @param [String, #id] vector The ID of the vector store
    # @param query [String] The query to search for
    # @param params [Hash] Other parameters (see OpenAI docs)
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response]
    # @see https://platform.openai.com/docs/api-reference/vector_stores/search OpenAI docs
    def search(vector:, query:, **params)
      vector_id = vector.respond_to?(:id) ? vector.id : vector
      req = Net::HTTP::Post.new("/v1/vector_stores/#{vector_id}/search", headers)
      req.body = JSON.dump(params.merge({query:}).compact)
      res = execute(request: req)
      LLM::Response.new(res)
    end

    private

    [:headers, :execute, :set_body_stream].each do |m|
      define_method(m) { |*args, **kwargs, &b| @provider.send(m, *args, **kwargs, &b) }
    end
  end
end
