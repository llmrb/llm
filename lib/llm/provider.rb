# frozen_string_literal: true

##
# The Provider class represents an abstract class for
# LLM (Language Model) providers.
#
# @abstract
class LLM::Provider
  require "net/http"

  ##
  # @param [String, nil] key
  #  The secret key for authentication
  # @param [String] host
  #  The host address of the LLM provider
  # @param [Integer] port
  #  The port number
  # @param [Integer] timeout
  #  The number of seconds to wait for a response
  # @param [Boolean] ssl
  #  Whether to use SSL for the connection
  def initialize(key:, host:, port: 443, timeout: 60, ssl: true)
    @key = key
    @client = Net::HTTP.new(host, port)
    @client.use_ssl = ssl
    @client.read_timeout = timeout
  end

  ##
  # Returns an inspection of the provider object
  # @return [String]
  # @note The secret key is redacted in inspect for security reasons
  def inspect
    "#<#{self.class.name}:0x#{object_id.to_s(16)} @key=[REDACTED] @http=#{@http.inspect}>"
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
  # @return [LLM::Response]
  def embed(input, model: nil, **params)
    raise NotImplementedError
  end

  ##
  # Provides an interface to the chat completions API
  # @example
  #   llm = LLM.openai(key: ENV["KEY"])
  #   messages = [{role: "system", content: "Your task is to answer all of my questions"}]
  #   res = llm.complete("5 + 2 ?", messages:)
  #   print "[#{res.choices[0].role}]", res.choices[0].content, "\n"
  # @param [String] prompt
  #  The input prompt to be completed
  # @param [Hash] params
  #  The parameters to maintain throughout the conversation.
  #  Any parameter the provider supports can be included and
  #  not only those listed here.
  # @option params [Symbol] :role Defaults to the provider's default role
  # @option params [String] :model Defaults to the provider's default model
  # @option params [#to_json, nil] :schema Defaults to nil
  # @option params [Array<LLM::Function>, nil] :tools Defaults to nil
  # @raise [NotImplementedError]
  #  When the method is not implemented by a subclass
  # @return [LLM::Response]
  def complete(prompt, params = {})
    raise NotImplementedError
  end

  ##
  # Starts a new lazy chat powered by the chat completions API
  # @note
  #  This method creates a lazy version of a
  #  {LLM::Bot LLM::Bot} object.
  # @param prompt (see LLM::Provider#complete)
  # @param params (see LLM::Provider#complete)
  # @return [LLM::Bot]
  def chat(prompt, params = {})
    role = params.delete(:role)
    LLM::Bot.new(self, params).chat(prompt, role:)
  end

  ##
  # Starts a new chat powered by the chat completions API
  # @note
  #  This method creates a non-lazy version of a
  #  {LLM::Bot LLM::Bot} object.
  # @param prompt (see LLM::Provider#complete)
  # @param params (see LLM::Provider#complete)
  # @raise (see LLM::Provider#complete)
  # @return [LLM::Bot]
  def chat!(prompt, params = {})
    role = params.delete(:role)
    LLM::Bot.new(self, params).chat(prompt, role:)
  end

  ##
  # Starts a new lazy chat powered by the responses API
  # @note
  #  This method creates a lazy variant of a
  #  {LLM::Bot LLM::Bot} object.
  # @param prompt (see LLM::Provider#complete)
  # @param params (see LLM::Provider#complete)
  # @raise (see LLM::Provider#complete)
  # @return [LLM::Bot]
  def respond(prompt, params = {})
    role = params.delete(:role)
    LLM::Bot.new(self, params).respond(prompt, role:)
  end

  ##
  # Starts a new chat powered by the responses API
  # @note
  #  This method creates a non-lazy variant of a
  #  {LLM::Bot LLM::Bot} object.
  # @param prompt (see LLM::Provider#complete)
  # @param params (see LLM::Provider#complete)
  # @raise (see LLM::Provider#complete)
  # @return [LLM::Bot]
  def respond!(prompt, params = {})
    role = params.delete(:role)
    LLM::Bot.new(self, params).respond(prompt, role:)
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
  # @return [LLM::OpenAI::Moderations]
  #  Returns an interface to the moderations API
  def moderations
    raise NotImplementedError
  end

  ##
  # @return [LLM::OpenAI::VectorStore]
  #  Returns an interface to the vector stores API
  def vector_stores
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

  ##
  # Returns an object that can generate a JSON schema
  # @return [LLM::Schema]
  def schema
    @schema ||= LLM::Schema.new
  end

  ##
  # Add one or more headers to all requests
  # @example
  #   llm = LLM.openai(key: ENV["KEY"])
  #   llm.with(headers: {"OpenAI-Organization" => ENV["ORG"]})
  #   llm.with(headers: {"OpenAI-Project" => ENV["PROJECT"]})
  # @param [Hash<String,String>] headers
  #  One or more headers
  # @return [LLM::Provider]
  #  Returns self
  def with(headers:)
    tap { (@headers ||= {}).merge!(headers) }
  end

  private

  attr_reader :client

  ##
  # The headers to include with a request
  # @raise [NotImplementedError]
  #  (see LLM::Provider#complete)
  def headers
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
  # @return [Class]
  def event_handler
    LLM::EventHandler
  end

  ##
  # @return [Class]
  #  Returns the provider-specific Server-Side Events (SSE) parser
  def stream_parser
    raise NotImplementedError
  end

  ##
  # Executes a HTTP request
  # @param [Net::HTTPRequest] request
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
  # @return [Net::HTTPResponse]
  def execute(request:, stream: nil, stream_parser: self.stream_parser, &b)
    res = if stream
      client.request(request) do |res|
        handler = event_handler.new stream_parser.new(stream)
        parser = LLM::EventStream::Parser.new
        parser.register(handler)
        res.read_body(parser)
        # If the handler body is empty, it means the
        # response was most likely not streamed or
        # parsing has failed. In that case, we fallback
        # on the original response body.
        res.body = handler.body.empty? ? parser.body.dup : handler.body
      ensure
        parser&.free
      end
    else
      b ? client.request(request) { (Net::HTTPSuccess === _1) ? b.call(_1) : _1 } :
          client.request(request)
    end
    handle_response(res)
  end

  ##
  # Handles the response from a request
  # @param [Net::HTTPResponse] res
  #  The response to handle
  # @return [Net::HTTPResponse]
  def handle_response(res)
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
