# frozen_string_literal: true

class LLM::Gemini
  ##
  # The {LLM::Gemini::Audio LLM::Gemini::Audio} class provides an audio
  # object for interacting with [Gemini's audio API](https://ai.google.dev/gemini-api/docs/audio).
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.openai(ENV["KEY"])
  #   res = llm.audio.create_transcription(input: LLM::File("/rocket.mp3"))
  #   res.text # => "A dog on a rocket to the moon"
  class Audio
    ##
    # Returns a new Audio object
    # @param provider [LLM::Provider]
    # @return [LLM::Gemini::Responses]
    def initialize(provider)
      @provider = provider
    end

    ##
    # @raise [NotImplementedError]
    #  This method is not implemented by Gemini
    def create_speech
      raise NotImplementedError
    end

    ##
    # Create an audio transcription
    # @example
    #   llm = LLM.gemini(ENV["KEY"])
    #   res = llm.audio.create_transcription(file: LLM::File("/rocket.mp3"))
    #   res.text # => "A dog on a rocket to the moon"
    # @see https://ai.google.dev/gemini-api/docs/audio Gemini docs
    # @param [LLM::File, LLM::Response::File] file The input audio
    # @param [String] model The model to use
    # @param [Hash] params Other parameters (see Gemini docs)
    # @raise (see LLM::HTTPClient#request)
    # @return [LLM::Response::AudioTranscription]
    def create_transcription(file:, model: "gemini-1.5-flash", **params)
      res = @provider.complete [
        "Your task is to transcribe the contents of an audio file",
        "Your response should include the transcription, and nothing else",
        file
      ], :user, model:, **params
      LLM::Response::AudioTranscription
        .new(res)
        .tap { _1.text = res.choices[0].content }
    end

    ##
    # Create an audio translation (in English)
    # @example
    #   # Arabic => English
    #   llm = LLM.gemini(ENV["KEY"])
    #   res = llm.audio.create_translation(file: LLM::File("/bismillah.mp3"))
    #   res.text # => "In the name of Allah, the Beneficent, the Merciful."
    # @see https://ai.google.dev/gemini-api/docs/audio Gemini docs
    # @param [LLM::File, LLM::Response::File] file The input audio
    # @param [String] model The model to use
    # @param [Hash] params Other parameters (see Gemini docs)
    # @raise (see LLM::HTTPClient#request)
    # @return [LLM::Response::AudioTranslation]
    def create_translation(file:, model: "gemini-1.5-flash", **params)
      res = @provider.complete [
        "Your task is to translate the contents of an audio file into English",
        "Your response should include the translation, and nothing else",
        file
      ], :user, model:, **params
      LLM::Response::AudioTranslation
        .new(res)
        .tap { _1.text = res.choices[0].content }
    end
  end
end
