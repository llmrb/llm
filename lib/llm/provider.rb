# frozen_string_literal: true

##
# The Provider class represents an abstract class for
# LLM (Language Model) providers.
#
# @abstract
class LLM::Provider
  require "net/http"

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
  def embed(input, model: nil, **params)
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
  def complete(prompt, role = :user, model: default_model, **params)
    raise NotImplementedError
  end

  ##
  # Starts a new lazy chat powered by the chat completions API
  # @note
  #  This method creates a lazy version of a
  #  {LLM::Chat LLM::Chat} object.
  # @param prompt (see LLM::Provider#complete)
  # @param role (see LLM::Provider#complete)
  # @param model (see LLM::Provider#complete)
  # @param [Hash] params
  #  Other completion parameters to maintain throughout a chat
  # @raise (see LLM::Provider#complete)
  # @return [LLM::Chat]
  def chat(prompt, role = :user, model: default_model, **params)
    LLM::Chat.new(self, **params.merge(model:)).lazy.chat(prompt, role)
  end

  ##
  # Starts a new chat powered by the chat completions API
  # @note
  #  This method creates a non-lazy version of a
  #  {LLM::Chat LLM::Chat} object.
  # @param prompt (see LLM::Provider#complete)
  # @param role (see LLM::Provider#complete)
  # @param model (see LLM::Provider#complete)
  # @param [Hash] params
  #  Other completion parameters to maintain throughout a chat
  # @raise (see LLM::Provider#complete)
  # @return [LLM::Chat]
  def chat!(prompt, role = :user, model: default_model, **params)
    LLM::Chat.new(self, **params.merge(model:)).chat(prompt, role)
  end

  ##
  # Starts a new lazy chat powered by the responses API
  # @note
  #  This method creates a lazy variant of a
  #  {LLM::Chat LLM::Chat} object.
  # @param prompt (see LLM::Provider#complete)
  # @param role (see LLM::Provider#complete)
  # @param model (see LLM::Provider#complete)
  # @param [Hash] params
  #  Other completion parameters to maintain throughout a chat
  # @raise (see LLM::Provider#complete)
  # @return [LLM::Chat]
  def respond(prompt, role = :user, model: default_model, **params)
    LLM::Chat.new(self, **params.merge(model:)).lazy.respond(prompt, role)
  end

  ##
  # Starts a new chat powered by the responses API
  # @note
  #  This method creates a non-lazy variant of a
  #  {LLM::Chat LLM::Chat} object.
  # @param prompt (see LLM::Provider#complete)
  # @param role (see LLM::Provider#complete)
  # @param model (see LLM::Provider#complete)
  # @param [Hash] params
  #  Other completion parameters to maintain throughout a chat
  # @raise (see LLM::Provider#complete)
  # @return [LLM::Chat]
  def respond!(prompt, role = :user, model: default_model, **params)
    LLM::Chat.new(self, **params.merge(model:)).respond(prompt, role)
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
  # @return [LLM::OpenAI::Images, LLM::Gemini::Images]
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
  # @return [LLM::OpenAI::Files]
  #  Returns an interface to the files API
  def files
    raise NotImplementedError
  end

  ##
  # @return [LLM::OpenAI::Models]
  #  Returns an interface to the models API
  def models
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
  # @return [String]
  #  Returns the default model for chat completions
  def default_model
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
  # Initiates a HTTP request
  # @param [Net::HTTP] http
  #  The HTTP object to use for the request
  # @param [Net::HTTPRequest] req
  #  The request to send
  # @param [Proc] b
  #  A block to yield the response to (optional)
  # @return [Net::HTTPResponse]
  #  The response from the server
  # @raise [LLM::Error::Unauthorized]
  #  When authentication fails
  # @raise [LLM::Error::RateLimit]
  #  When the rate limit is exceeded
  # @raise [LLM::Error::ResponseError]
  #  When any other unsuccessful status code is returned
  # @raise [SystemCallError]
  #  When there is a network error at the operating system level
  def request(http, req, &b)
    res = http.request(req, &b)
    case res
    when Net::HTTPOK then res
    else error_handler.new(res).raise_error!
    end
  end

  ##
  # @param [Net::HTTPRequest] req
  #  The request to set the body stream for
  # @param [IO] io
  #  The IO object to set as the body stream
  # @return [void]
  def set_body_stream(req, io)
    req.body_stream = io
    req["transfer-encoding"] = "chunked" unless req["content-length"]
  end
end
