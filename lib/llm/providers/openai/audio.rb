# frozen_string_literal: true

class LLM::OpenAI
  ##
  # The {LLM::OpenAI::Audio LLM::OpenAI::Audio} class provides an audio
  # object for interacting with [OpenAI's audio API](https://platform.openai.com/docs/api-reference/audio/createSpeech).
  # @example
  #   llm = LLM.openai(ENV["KEY"])
  #   res = llm.audio.create_speech input: "A dog on a rocket to the moon"
  #   File.binwrite "rocket.mp3", res.audio.string
  class Audio
    require "stringio"

    ##
    # Returns a new Responses object
    # @param provider [LLM::Provider]
    # @return [LLM::OpenAI::Responses]
    def initialize(provider)
      @provider = provider
    end

    ##
    # Create an audio track
    # @example
    #   llm = LLM.openai(ENV["KEY"])
    #   res = llm.images.create_speech(input: "A dog on a rocket to the moon")
    #   File.binwrite("rocket.mp3", res.audio.string)
    # @see https://platform.openai.com/docs/api-reference/audio/createSpeech OpenAI docs
    # @param [String] input The text input
    # @param [String] voice The voice to use
    # @param [String] model The model to use
    # @param [String] response_format The response format
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::HTTPClient#request)
    # @return [OpenStruct]
    def create_speech(input:, voice: "alloy", model: "gpt-4o-mini-tts", response_format: "mp3", **params)
      req = Net::HTTP::Post.new("/v1/audio/speech", headers)
      req.body = JSON.dump({input:, voice:, model:, response_format:}.merge!(params))
      io = StringIO.new("".b)
      res = request(http, req) { _1.read_body { |chunk| io << chunk } }
      OpenStruct.from_hash(response: res, audio: io)
    end

    ##
    # Create an audio transcription
    # @example
    #   llm = LLM.openai(ENV["KEY"])
    #   res = llm.audio.create_transcription(file: LLM::File("/rocket.mp3"))
    #   res.text # => "A dog on a rocket to the moon"
    # @see https://platform.openai.com/docs/api-reference/audio/createTranscription OpenAI docs
    # @param [LLM::File] file The input audio
    # @param [String] model The model to use
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::HTTPClient#request)
    # @return [OpenStruct]
    def create_transcription(file:, model: "whisper-1", **params)
      multi = LLM::Multipart.new(params.merge!(file:, model:))
      req = Net::HTTP::Post.new("/v1/audio/transcriptions", headers)
      req["content-type"] = multi.content_type
      req.body = multi.body
      res = request(http, req)
      OpenStruct.from_hash({response: res}.merge(JSON.parse(res.body)))
    end

    ##
    # Create an audio translation (in English)
    # @example
    #   # Arabic => English
    #   llm = LLM.openai(ENV["KEY"])
    #   res = llm.audio.create_translation(file: LLM::File("/bismillah.mp3"))
    #   res.text # => "In the name of Allah, the Beneficent, the Merciful."
    # @see https://platform.openai.com/docs/api-reference/audio/createTranslation OpenAI docs
    # @param [LLM::File] file The input audio
    # @param [String] model The model to use
    # @param [Hash] params Other parameters (see OpenAI docs)
    # @raise (see LLM::HTTPClient#request)
    # @return [OpenStruct]
    def create_translation(file:, model: "whisper-1", **params)
      multi = LLM::Multipart.new(params.merge!(file:, model:))
      req = Net::HTTP::Post.new("/v1/audio/translations", headers)
      req["content-type"] = multi.content_type
      req.body = multi.body
      res = request(http, req)
      OpenStruct.from_hash({response: res}.merge(JSON.parse(res.body)))
    end

    private

    def http
      @provider.instance_variable_get(:@http)
    end

    [:headers, :request].each do |m|
      define_method(m) { |*args, &b| @provider.send(m, *args, &b) }
    end
  end
end
