# frozen_string_literal: true

##
# The {LLM::Model LLM::Model} class represents an LLM model that
# is available to use. Its properties are delegated to the underlying
# response body, and vary by provider.
class LLM::Model < LLM::Object
  ##
  # Returns a subclass of {LLM::Provider LLM::Provider}
  # @return [LLM::Provider]
  attr_accessor :provider

  ##
  # Returns the model ID
  # @return [String]
  def id
    case @provider.class.to_s
    when "LLM::Ollama"
      self["name"]
    when "LLM::Gemini"
      self["name"].sub(%r|\Amodels/|, "")
    else
      self["id"]
    end
  end

  ##
  # @return [String]
  def to_json(*)
    id.to_json(*)
  end
end
