# frozen_string_literal: true

module LLM
  require_relative "llm/version"
  require_relative "llm/error"
  require_relative "llm/message"
  require_relative "llm/response"
  require_relative "llm/file"
  require_relative "llm/model"
  require_relative "llm/provider"
  require_relative "llm/conversation"
  require_relative "llm/lazy_conversation"
  require_relative "llm/core_ext/ostruct"

  module_function

  ##
  # @param secret (see LLM::Anthropic#initialize)
  # @return (see LLM::Anthropic#initialize)
  def anthropic(secret, **)
    require_relative "llm/providers/anthropic" unless defined?(LLM::Anthropic)
    require_relative "llm/providers/voyageai" unless defined?(LLM::VoyageAI)
    LLM::Anthropic.new(secret, **)
  end

  ##
  # @param secret (see LLM::VoyageAI#initialize)
  # @return (see LLM::VoyageAI#initialize)
  def voyageai(secret, **)
    require_relative "llm/providers/voyageai" unless defined?(LLM::VoyageAI)
    LLM::VoyageAI.new(secret, **)
  end

  ##
  # @param secret (see LLM::Gemini#initialize)
  # @return (see LLM::Gemini#initialize)
  def gemini(secret, **)
    require_relative "llm/providers/gemini" unless defined?(LLM::Gemini)
    LLM::Gemini.new(secret, **)
  end

  ##
  # @param host (see LLM::Ollama#initialize)
  # @return (see LLM::Ollama#initialize)
  def ollama(secret, **)
    require_relative "llm/providers/ollama" unless defined?(LLM::Ollama)
    LLM::Ollama.new(secret, **)
  end

  ##
  # @param secret (see LLM::OpenAI#initialize)
  # @return (see LLM::OpenAI#initialize)
  def openai(secret, **)
    require_relative "llm/providers/openai" unless defined?(LLM::OpenAI)
    LLM::OpenAI.new(secret, **)
  end
end
