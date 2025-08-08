# frozen_string_literal: true

##
# The {LLM::Object LLM::Object} class encapsulates a Hash object, and it
# allows a consumer to get and set Hash keys via regular methods. It is
# similar in spirit to OpenStruct, and it was introduced after OpenStruct
# became a bundled gem (and not a default gem) in Ruby 3.5.
class LLM::Object < BasicObject
  require_relative "object/builder"
  require_relative "object/kernel"

  extend Builder
  include Kernel
  include ::Enumerable
  defined?(::PP) ? include(::PP::ObjectMixin) : nil

  ##
  # @param [Hash] h
  # @return [LLM::Object]
  def initialize(h = {})
    @h = h.transform_keys(&:to_sym) || h
  end

  ##
  # Yields a key|value pair to a block.
  # @yieldparam [Symbol] k
  # @yieldparam [Object] v
  # @return [void]
  def each(&)
    @h.each(&)
  end

  ##
  # @param [Symbol, #to_sym] k
  # @return [Object]
  def [](k)
    @h[k.to_sym]
  end

  ##
  # @param [Symbol, #to_sym] k
  # @param [Object] v
  # @return [void]
  def []=(k, v)
    @h[k.to_sym] = v
  end

  ##
  # @return [String]
  def to_json(...)
    to_h.to_json(...)
  end

  ##
  # @return [Boolean]
  def empty?
    @h.empty?
  end

  ##
  # @return [Hash]
  def to_h
    @h
  end
  alias_method :to_hash, :to_h

  ##
  # @return [Object, nil]
  def dig(...)
    to_h.dig(...)
  end

  private

  def method_missing(m, *args, &b)
    if m.to_s.end_with?("=")
      @h[m[0..-2].to_sym] = args.first
    elsif @h.key?(m)
      @h[m]
    else
      nil
    end
  end
end
