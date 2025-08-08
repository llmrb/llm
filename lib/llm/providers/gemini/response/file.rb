# frozen_string_literal: true

module LLM::Gemini::Response
  module File
    def name = respond_to?(:file) ? file.name : body.name
    def display_name = respond_to?(:file) ? file.displayName : body.displayName
    def mime_type = respond_to?(:file) ? file.mimeType : body.mimeType
    def uri = respond_to?(:file) ? file.uri : body.uri
    def file? = true
  end
end
