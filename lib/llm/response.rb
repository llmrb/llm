# frozen_string_literal: true

module LLM
  class Response
    require "json"
    require_relative "response/completion"
    require_relative "response/embedding"
    require_relative "response/respond"
    require_relative "response/image"
    require_relative "response/audio"
    require_relative "response/audio_transcription"
    require_relative "response/audio_translation"
    require_relative "response/file"
    require_relative "response/filelist"
    require_relative "response/download_file"
    require_relative "response/modellist"

    ##
    # @param [Net::HTTPResponse] res
    #  HTTP response
    # @return [LLM::Response]
    #  Returns an instance of LLM::Response
    def initialize(res)
      @res = res
    end

    ##
    # Returns the response body
    # @return [Hash, String]
    def body
      @body ||= case @res["content-type"]
      when %r|\Aapplication/json\s*| then JSON.parse(@res.body)
      else @res.body
      end
    end
  end
end
