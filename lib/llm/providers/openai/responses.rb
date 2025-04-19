# frozen_string_literal: true

class LLM::OpenAI
  ##
  # The {LLM::OpenAI::Responses LLM::OpenAI::Responses} class provides a responses
  # object for interacting with [OpenAI's response API](https://platform.openai.com/docs/guides/conversation-state?api-mode=responses).
  # @example
  #   llm = LLM.openai(ENV["KEY"])
  #   res1 = llm.responses.create "Your task is to help me with math", :developer
  #   res2 = llm.responses.create "5 + 5  = ?", :user, previous_response_id: res1.id
  #   [res1,res2].each { llm.responses.delete(_1) }
  class Responses
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
    # @param role (see LLM::Provider#complete)
    # @param model (see LLM::Provider#complete)
    # @param [Hash] params Response params
    # @raise (see LLM::HTTPClient#request)
    # @return [LLM::Response::Output]
    def create(prompt, role = :user, model: "gpt-4o-mini", **params)
      params   = {model:}.merge!(params)
      req      = Net::HTTP::Post.new("/v1/responses", headers)
      messages = [*(params.delete(:input) || []), LLM::Message.new(role, prompt)]
      req.body = JSON.dump({input: format(messages)}.merge!(params))
      res      = request(http, req)
      LLM::Response::Output.new(res).extend(response_parser)
    end

    ##
    # Get a response
    # @see https://platform.openai.com/docs/api-reference/responses/get OpenAI docs
    # @param [#id, #to_s] response Response ID
    # @raise (see LLM::HTTPClient#request)
    # @return [LLM::Response::Output]
    def get(response, **params)
      response_id = response.respond_to?(:id) ? response.id : response
      query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new("/v1/responses/#{response_id}?#{query}", headers)
      res = request(http, req)
      LLM::Response::Output.new(res).extend(response_parser)
    end

    ##
    # Deletes a response
    # @see https://platform.openai.com/docs/api-reference/responses/delete OpenAI docs
    # @param [#id, #to_s] response Response ID
    # @raise (see LLM::HTTPClient#request)
    # @return [OpenStruct] Response body
    def delete(response)
      response_id = response.respond_to?(:id) ? response.id : response
      req = Net::HTTP::Delete.new("/v1/responses/#{response_id}", headers)
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
