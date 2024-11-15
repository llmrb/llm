# frozen_string_literal: true

module LLM
  require "llm/http_client"
  ##
  # The Provider class represents an abstract class for
  # LLM (Language Model) providers
  class Provider
    include HTTPClient
    ##
    # @param [String] secret
    #  The secret key for authentication
    # @param [String] host
    #  The host address of the LLM provider
    # @param [Integer] port
    #  The port number
    def initialize(secret, host:, port: 443, ssl: true)
      @secret = secret
      @http = Net::HTTP.new(host, port).tap do |http|
        http.use_ssl = ssl
      end
    end

    ##
    # Returns an inspection of the provider object
    # @return [String]
    # @note The secret key is redacted in inspect for security reasons
    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} @secret=[REDACTED] @http=#{@http.inspect}>"
    end

    ##
    # Completes a given prompt using the LLM
    # @param [String] prompt
    #  The input prompt to be completed
    # @param [Symbol] role
    #  The role of the prompt (e.g. :user, :system)
    # @raise [NotImplementedError]
    #  When the method is not implemented by a subclass
    # @return [LLM::Response::Completion]
    def complete(prompt, role = :user, **params)
      raise NotImplementedError
    end

    ##
    # Starts a new lazy conversation
    # @param prompt (see LLM::Provider#complete)
    # @param role (see LLM::Provider#complete)
    # @raise (see LLM::Provider#complete)
    # @return [LLM::LazyConversation]
    def chat(prompt, role = :user, **params)
      LazyConversation.new(self).chat(prompt, role, **params)
    end

    ##
    # Starts a new conversation
    # @param prompt (see LLM::Provider#complete)
    # @param role (see LLM::Provider#complete)
    # @raise (see LLM::Provider#complete)
    # @return [LLM::Conversation]
    def chat!(prompt, role = :user, **params)
      prompt = transform_prompt(prompt)
      completion = complete(Message.new(role, prompt), **params)
      thread = [*params[:messages], Message.new(role.to_s, prompt), completion.choices.first]
      Conversation.new(self, thread).chat(prompt, role, **params)
    end

    ##
    # Transforms the prompt before sending it
    # @param [String, URI, Object] prompt
    #  The prompt to transform
    # @return [Object]
    #  The transformed prompt
    def transform_prompt(prompt)
      prompt
    end

    private

    ##
    # Prepares a request for authentication
    # @param [Net::HTTP::Request] req
    #  The request to prepare for authentication
    # @raise [NotImplementedError]
    #  (see LLM::Provider#complete)
    def auth(req)
      raise NotImplementedError
    end

    ##
    # @return [Module]
    #  Returns the module responsible for parsing a successful LLM response
    # @raise [NotImplementedError]
    #  (see LLM::Provider#complete)
    def response_parser
      raise NotImplementedError
    end

    ##
    # @return [Class]
    #  Returns the class responsible for handling an unsuccessful LLM response
    # @raise [NotImplementedError]
    #  (see LLM::Provider#complete)
    def error_handler
      raise NotImplementedError
    end

    ##
    # Prepares a request before sending it
    def preflight(req, body)
      req.content_type = "application/json"
      req.body = JSON.generate(body)
      auth(req)
      req
    end
  end
end
