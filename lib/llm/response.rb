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
    require_relative "response/moderationlist"

    ##
    # Returns the HTTP response
    # @return [Net::HTTPResponse]
    attr_reader :res

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

    ##
    # Returns an inspection of the response object
    # @return [String]
    def inspect
      "#<#{self.class.name}:0x#{object_id.to_s(16)} @body=#{body.inspect} @res=#{@res.inspect}>"
    end

    private

    def method_missing(m, *args, **kwargs, &b)
      body.key?(m.to_s) ? body[m.to_s] : super
    end

    def respond_to_missing?(m, include_private = false)
      body.key?(m.to_s) || super
    end
  end
end
