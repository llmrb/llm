# frozen_string_literal: true

module LLM::Anthropic::Response
  module File
    ##
    # Always return true
    # @return [Boolean]
    def file? = true

    ##
    # Returns the file type referenced by a prompt
    # @return [Symbol]
    def file_type
      if mime_type.start_with?("image/")
        :image
      elsif mime_type == "text/plain" || mime_type == "application/pdf"
        :document
      else
        :container_upload
      end
    end
  end
end
