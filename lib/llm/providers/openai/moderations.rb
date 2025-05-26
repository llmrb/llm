# frozen_string_literal: true

class LLM::OpenAI
  ##
  # The {LLM::OpenAI::Moderations LLM::OpenAI::Moderations} class provides a moderations
  # object for interacting with [OpenAI's moderations API](https://platform.openai.com/docs/api-reference/moderations).
  # The moderations API can categorize content into different categories, such as
  # hate speech, self-harm, and sexual content. It can also provide a confidence score
  # for each category.
  #
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.openai(key: ENV["KEY"])
  #   mod = llm.moderations.create input: "I hate you"
  #   print "categories: #{mod.categories}", "\n"
  #   print "scores: #{mod.scores}", "\n"
  #
  # @example
  #   #!/usr/bin/env ruby
  #   require "llm"
  #
  #   llm = LLM.openai(key: ENV["KEY"])
  #   mod = llm.moderations.create input: URI.parse("https://example.com/image.png")
  #   print "categories: #{mod.categories}", "\n"
  #   print "scores: #{mod.scores}", "\n"
  #
  # @see https://platform.openai.com/docs/api-reference/moderations/create OpenAI docs
  # @see https://platform.openai.com/docs/models#moderation OpenAI moderation models
  class Moderations
    ##
    # Returns a new Moderations object
    # @param [LLM::Provider] provider
    # @return [LLM::OpenAI::Moderations]
    def initialize(provider)
      @provider = provider
    end

    ##
    # Create a moderation
    # @see https://platform.openai.com/docs/api-reference/moderations/create OpenAI docs
    # @see https://platform.openai.com/docs/models#moderation OpenAI moderation models
    # @note
    # Although OpenAI mentions an array as a valid input, and that it can return one
    # or more moderations, in practice the API only returns one moderation object. We
    # recommend using a single input string or URI, and to keep in mind that llm.rb
    # returns a Moderation object but has code in place to return multiple objects in
    # the future (in case OpenAI documentation ever matches the actual API).
    # @param [String, URI, Array<String, URI>] input
    # @param [String, LLM::Model] model The model to use
    # @return [LLM::Response::ModerationList::Moderation]
    def create(input:, model: "omni-moderation-latest", **params)
      req = Net::HTTP::Post.new("/v1/moderations", headers)
      input = Format::ModerationFormat.new(input).format
      req.body = JSON.dump({input:, model:}.merge!(params))
      res = execute(client: http, request: req)
      LLM::Response::ModerationList.new(res).extend(response_parser).first
    end

    private

    def http
      @provider.instance_variable_get(:@http)
    end

    [:response_parser, :headers, :execute].each do |m|
      define_method(m) { |*args, **kwargs, &b| @provider.send(m, *args, **kwargs, &b) }
    end
  end
end
