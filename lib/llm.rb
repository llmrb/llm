# frozen_string_literal: true

module LLM
  require "stringio"
  require_relative "llm/schema"
  require_relative "llm/object"
  require_relative "llm/version"
  require_relative "llm/utils"
  require_relative "llm/error"
  require_relative "llm/message"
  require_relative "llm/response"
  require_relative "llm/mime"
  require_relative "llm/multipart"
  require_relative "llm/file"
  require_relative "llm/provider"
  require_relative "llm/bot"
  require_relative "llm/buffer"
  require_relative "llm/function"
  require_relative "llm/eventstream"
  require_relative "llm/eventhandler"
  require_relative "llm/tool"

  module_function

  ##
  # @param (see LLM::Provider#initialize)
  # @return (see LLM::Anthropic#initialize)
  def anthropic(**)
    require_relative "llm/providers/anthropic" unless defined?(LLM::Anthropic)
    LLM::Anthropic.new(**)
  end

  ##
  # @param (see LLM::Provider#initialize)
  # @return (see LLM::Gemini#initialize)
  def gemini(**)
    require_relative "llm/providers/gemini" unless defined?(LLM::Gemini)
    LLM::Gemini.new(**)
  end

  ##
  # @param key (see LLM::Provider#initialize)
  # @return (see LLM::Ollama#initialize)
  def ollama(key: nil, **)
    require_relative "llm/providers/ollama" unless defined?(LLM::Ollama)
    LLM::Ollama.new(key:, **)
  end

  ##
  # @param key (see LLM::Provider#initialize)
  # @return (see LLM::LlamaCpp#initialize)
  def llamacpp(key: nil, **)
    require_relative "llm/providers/llamacpp" unless defined?(LLM::LlamaCpp)
    LLM::LlamaCpp.new(key:, **)
  end

  ##
  # @param key (see LLM::Provider#initialize)
  # @return (see LLM::DeepSeek#initialize)
  def deepseek(**)
    require_relative "llm/providers/deepseek" unless defined?(LLM::DeepSeek)
    LLM::DeepSeek.new(**)
  end

  ##
  # @param key (see LLM::Provider#initialize)
  # @return (see LLM::OpenAI#initialize)
  def openai(**)
    require_relative "llm/providers/openai" unless defined?(LLM::OpenAI)
    LLM::OpenAI.new(**)
  end

  ##
  # @param key (see LLM::XAI#initialize)
  # @param host (see LLM::XAI#initialize)
  # @return (see LLM::XAI#initialize)
  def xai(**)
    require_relative "llm/providers/xai" unless defined?(LLM::XAI)
    LLM::XAI.new(**)
  end

  ##
  # Define or get a function
  # @example
  #   LLM.function(:system) do |fn|
  #     fn.description "Run system command"
  #     fn.params do |schema|
  #       schema.object(command: schema.string.required)
  #     end
  #     fn.define do |command:|
  #       system(command)
  #     end
  #   end
  # @param [Symbol] name The name of the function
  # @param [Proc] b The block to define the function
  # @return [LLM::Function] The function object
  def function(name, &b)
    if block_given?
      functions[name.to_s] = LLM::Function.new(name, &b)
    else
      functions[name.to_s]
    end
  end

  ##
  # Returns all known functions
  # @return [Hash<String,LLM::Function>]
  def functions
    @functions ||= {}
  end
end
