# frozen_string_literal: true

module LLM::OpenAI::Response
  module Audio
    def audio = body.audio
  end
end
