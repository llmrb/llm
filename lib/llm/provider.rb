# frozen_string_literal: true

##
# The Provider class represents an abstract class for
# LLM (Language Model) providers
class LLM::Provider
  require_relative "http_client"
  include LLM::HTTPClient

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
  # @param [String, Array<String>] input
  #  The input to embed
  # @raise [NotImplementedError]
  #  When the method is not implemented by a subclass
  # @return [LLM::Response::Embedding]
  def embed(input, **params)
    raise NotImplementedError
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
    LLM::LazyConversation.new(self, params).chat(prompt, role)
  end

  ##
  # Starts a new conversation
  # @param prompt (see LLM::Provider#complete)
  # @param role (see LLM::Provider#complete)
  # @raise (see LLM::Provider#complete)
  # @return [LLM::Conversation]
  def chat!(prompt, role = :user, **params)
    LLM::Conversation.new(self, params).chat(prompt, role)
  end

  ##
  # @return [String]
  #  The role of the assistant in the conversation.
  #  Usually "assistant" or "model"
  def assistant_role
    raise NotImplementedError
  end

  ##
  # @return [Hash<String, LLM::Model>]
  #  A hash of available models
  def models
    raise NotImplementedError
  end

  private

  ##
  # The headers to include with a request
  # @raise [NotImplementedError]
  #  (see LLM::Provider#complete)
  def headers
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
  # @param [String] provider
  #  The name of the provider
  # @return [Hash<String, Hash>]
  def load_models!(provider)
    require "yaml" unless defined?(YAML)
    rootdir  = File.realpath File.join(__dir__, "..", "..")
    sharedir = File.join(rootdir, "share", "llm")
    provider = provider.gsub(/[^a-z0-9]/i, "")
    yaml     = File.join(sharedir, "models", "#{provider}.yml")
    YAML.safe_load_file(yaml).transform_values { LLM::Model.new(_1) }
  end
end
