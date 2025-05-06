# frozen_string_literal: true

module LLM
  require "stringio"
  require_relative "json/schema"
  require_relative "llm/core_ext/ostruct"
  require_relative "llm/version"
  require_relative "llm/utils"
  require_relative "llm/error"
  require_relative "llm/message"
  require_relative "llm/response"
  require_relative "llm/mime"
  require_relative "llm/multipart"
  require_relative "llm/file"
  require_relative "llm/model"
  require_relative "llm/provider"
  require_relative "llm/chat"
  require_relative "llm/buffer"
  require_relative "llm/function"

  module_function

  ##
  # @param secret (see LLM::Anthropic#initialize)
  # @return (see LLM::Anthropic#initialize)
  def anthropic(**)
    require_relative "llm/providers/anthropic" unless defined?(LLM::Anthropic)
    require_relative "llm/providers/voyageai" unless defined?(LLM::VoyageAI)
    LLM::Anthropic.new(**)
  end

  ##
  # @param secret (see LLM::VoyageAI#initialize)
  # @return (see LLM::VoyageAI#initialize)
  def voyageai(**)
    require_relative "llm/providers/voyageai" unless defined?(LLM::VoyageAI)
    LLM::VoyageAI.new(**)
  end

  ##
  # @param secret (see LLM::Gemini#initialize)
  # @return (see LLM::Gemini#initialize)
  def gemini(**)
    require_relative "llm/providers/gemini" unless defined?(LLM::Gemini)
    LLM::Gemini.new(**)
  end

  ##
  # @param host (see LLM::Ollama#initialize)
  # @return (see LLM::Ollama#initialize)
  def ollama(key: nil, **)
    require_relative "llm/providers/ollama" unless defined?(LLM::Ollama)
    LLM::Ollama.new(key:, **)
  end

  ##
  # @param secret (see LLM::OpenAI#initialize)
  # @return (see LLM::OpenAI#initialize)
  def openai(**)
    require_relative "llm/providers/openai" unless defined?(LLM::OpenAI)
    LLM::OpenAI.new(**)
  end

  ##
  # Define a function
  # @example
  # LLM.function(:system) do |fn|
  #   fn.description "Run system command"
  #   fn.params do |schema|
  #     schema.object(command: schema.string.required)
  #   end
  #   fn.define do |params|
  #     system(params.command)
  #   end
  # end
  # @param [Symbol] name The name of the function
  # @param [Proc] b The block to define the function
  # @return [LLM::Function] The function object
  def function(name, &b)
    functions[name.to_s] = LLM::Function.new(name, &b)
  end

  ##
  # Returns all known functions
  # @return [Hash<String,LLM::Function>]
  def functions
    @functions ||= {}
  end
end
