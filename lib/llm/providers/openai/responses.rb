# frozen_string_literal: true

class LLM::OpenAI
  ##
  # The {LLM::OpenAI::Responses LLM::OpenAI::Responses} class provides
  # an interface for [OpenAI's response API](https://platform.openai.com/docs/guides/conversation-state?api-mode=responses).
  #
  # @example example #1
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.openai(key: ENV["KEY"])
  #   res1 = llm.responses.create "Your task is to answer the user's questions", role: :developer
  #   res2 = llm.responses.create "5 + 5 = X ?", role: :user, previous_response_id: res1.id
  #   [res1, res2].each { llm.responses.delete(_1) }
  class Responses
    require_relative "response/responds"
    include Format

    ##
    # Returns a new Responses object
    # @param provider [LLM::Provider]
    # @return [LLM::OpenAI::Responses]
    def initialize(provider)
      @provider = provider
    end

    ##
    # Create a response
    # @see https://platform.openai.com/docs/api-reference/responses/create OpenAI docs
    # @param prompt (see LLM::Provider#complete)
    # @param params (see LLM::Provider#complete)
    # @raise (see LLM::Provider#request)
    # @raise [LLM::PromptError]
    #  When given an object a provider does not understand
    # @return [LLM::Response]
    def create(prompt, params = {})
      params = {role: :user, model: @provider.default_model}.merge!(params)
      params = [params, format_schema(params), format_tools(params)].inject({}, &:merge!).compact
      role = params.delete(:role)
      req = Net::HTTP::Post.new("/v1/responses", headers)
      messages = [*(params.delete(:input) || []), LLM::Message.new(role, prompt)]
      body = JSON.dump({input: [format(messages, :response)].flatten}.merge!(params))
      set_body_stream(req, StringIO.new(body))
      res = execute(request: req)
      LLM::Response.new(res).extend(LLM::OpenAI::Response::Responds)
    end

    ##
    # Get a response
    # @see https://platform.openai.com/docs/api-reference/responses/get OpenAI docs
    # @param [#id, #to_s] response Response ID
    # @raise (see LLM::Provider#request)
    # @return [LLM::Response]
    def get(response, **params)
      response_id = response.respond_to?(:id) ? response.id : response
      query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new("/v1/responses/#{response_id}?#{query}", headers)
      res = execute(request: req)
      LLM::Response.new(res).extend(LLM::OpenAI::Response::Responds)
    end

    ##
    # Deletes a response
    # @see https://platform.openai.com/docs/api-reference/responses/delete OpenAI docs
    # @param [#id, #to_s] response Response ID
    # @raise (see LLM::Provider#request)
    # @return [LLM::Object] Response body
    def delete(response)
      response_id = response.respond_to?(:id) ? response.id : response
      req = Net::HTTP::Delete.new("/v1/responses/#{response_id}", headers)
      res = execute(request: req)
      LLM::Response.new(res)
    end

    private

    [:headers, :execute,
     :set_body_stream, :format_schema,
     :format_tools].each do |m|
      define_method(m) { |*args, **kwargs, &b| @provider.send(m, *args, **kwargs, &b) }
    end

    def format_schema(params)
      return {} unless params && params[:schema]
      schema = params.delete(:schema)
      schema = schema.to_h.merge(additionalProperties: false)
      name = "JSONSchema"
      {text: {format: {type: "json_schema", name:, schema:}}}
    end
  end
end
