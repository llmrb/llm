# frozen_string_literal: true

##
# The Provider class represents an abstract class for
# LLM (Language Model) providers.
#
# @note
#  This class is not meant to be instantiated directly.
#  Instead, use one of the subclasses that implement
#  the methods defined here.
#
# @abstract
# @see LLM::Provider::OpenAI
# @see LLM::Provider::Anthropic
# @see LLM::Provider::Gemini
# @see LLM::Provider::Ollama
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
  # @param [Integer] timeout
  #  The number of seconds to wait for a response
  def initialize(secret, host:, port: 443, timeout: 60, ssl: true)
    @secret = secret
    @http = Net::HTTP.new(host, port).tap do |http|
      http.use_ssl = ssl
      http.read_timeout = timeout
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
  # Provides an embedding
  # @param [String, Array<String>] input
  #  The input to embed
  # @param [String] model
  #  The embedding model to use
  # @param [Hash] params
  #  Other embedding parameters
  # @raise [NotImplementedError]
  #  When the method is not implemented by a subclass
  # @return [LLM::Response::Embedding]
  def embed(input, model:, **params)
    raise NotImplementedError
  end

  ##
  # Provides an interface to the chat completions API
  # @example
  #   llm = LLM.openai(ENV["KEY"])
  #   messages = [
  #     {role: "system", content: "Your task is to answer all of my questions"},
  #     {role: "system", content: "Your answers should be short and concise"},
  #   ]
  #   res = llm.complete("Hello. What is the answer to 5 + 2 ?", :user, messages:)
  #   print "[#{res.choices[0].role}]", res.choices[0].content, "\n"
  # @param [String] prompt
  #  The input prompt to be completed
  # @param [Symbol] role
  #  The role of the prompt (e.g. :user, :system)
  # @param [String] model
  #  The model to use for the completion
  # @param [Hash] params
  #  Other completion parameters
  # @raise [NotImplementedError]
  #  When the method is not implemented by a subclass
  # @return [LLM::Response::Completion]
  def complete(prompt, role = :user, model:, **params)
    raise NotImplementedError
  end

  ##
  # Starts a new lazy conversation powered by the chat completions API
  # @note
  #  This method creates a lazy version of a
  #  {LLM::Conversation LLM::Conversation} object.
  # @param prompt (see LLM::Provider#complete)
  # @param role (see LLM::Provider#complete)
  # @param model (see LLM::Provider#complete)
  # @param [Hash] params
  #  Other completion parameters to maintain throughout a conversation
  # @raise (see LLM::Provider#complete)
  # @return [LLM::Conversation]
  def chat(prompt, role = :user, model: nil, **params)
    LLM::Conversation.new(self, params).lazy.chat(prompt, role)
  end

  ##
  # Starts a new conversation powered by the chat completions API
  # @note
  #  This method creates a non-lazy version of a
  #  {LLM::Conversation LLM::Conversation} object.
  # @param prompt (see LLM::Provider#complete)
  # @param role (see LLM::Provider#complete)
  # @param model (see LLM::Provider#complete)
  # @param [Hash] params
  #  Other completion parameters to maintain throughout a conversation
  # @raise (see LLM::Provider#complete)
  # @return [LLM::Conversation]
  def chat!(prompt, role = :user, model: nil, **params)
    LLM::Conversation.new(self, params).chat(prompt, role)
  end

  ##
  # Starts a new lazy conversation powered by the responses API
  # @note
  #  This method creates a lazy variant of a
  #  {LLM::Conversation LLM::Conversation} object.
  # @param prompt (see LLM::Provider#complete)
  # @param role (see LLM::Provider#complete)
  # @param model (see LLM::Provider#complete)
  # @param [Hash] params
  #  Other completion parameters to maintain throughout a conversation
  # @raise (see LLM::Provider#complete)
  # @return [LLM::Conversation]
  def respond(prompt, role = :user, model: nil, **params)
    LLM::Conversation.new(self, params).lazy.respond(prompt, role)
  end

  ##
  # Starts a new conversation powered by the responses API
  # @note
  #  This method creates a non-lazy variant of a
  #  {LLM::Conversation LLM::Conversation} object.
  # @param prompt (see LLM::Provider#complete)
  # @param role (see LLM::Provider#complete)
  # @param model (see LLM::Provider#complete)
  # @param [Hash] params
  #  Other completion parameters to maintain throughout a conversation
  # @raise (see LLM::Provider#complete)
  # @return [LLM::Conversation]
  def respond!(prompt, role = :user, model: nil, **params)
    LLM::Conversation.new(self, params).respond(prompt, role)
  end

  ##
  # @note
  # Compared to the chat completions API, the responses API
  # can require less bandwidth on each turn, maintain state
  # server-side, and produce faster responses.
  # @return [LLM::OpenAI::Responses]
  #  Returns an interface to the responses API
  def responses
    raise NotImplementedError
  end

  ##
  # @return [LLM::OpenAI::Images]
  #  Returns an interface to the images API
  def images
    raise NotImplementedError
  end

  ##
  # @return [LLM::OpenAI::Audio]
  #  Returns an interface to the audio API
  def audio
    raise NotImplementedError
  end

  ##
  # @return [String]
  #  Returns the role of the assistant in the conversation.
  #  Usually "assistant" or "model"
  def assistant_role
    raise NotImplementedError
  end

  ##
  # @return [Hash<String, LLM::Model>]
  #  Returns a hash of available models
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
