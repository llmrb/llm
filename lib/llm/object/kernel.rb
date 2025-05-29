# frozen_string_literal: true

class LLM::Object
  ##
  # @private
  module Kernel
    def tap(...)
      ::Kernel.instance_method(:tap).bind(self).call(...)
    end

    def instance_of?(...)
      ::Kernel.instance_method(:instance_of?).bind(self).call(...)
    end

    def method(...)
      ::Kernel.instance_method(:method).bind(self).call(...)
    end

    def kind_of?(...)
      ::Kernel.instance_method(:kind_of?).bind(self).call(...)
    end
    alias_method :is_a?, :kind_of?

    def respond_to?(m, include_private = false)
      @h.key?(m.to_sym) || self.class.instance_methods.include?(m) || super
    end

    def respond_to_missing?(m, include_private = false)
      @h.key?(m.to_sym) || super
    end

    def object_id
      ::Kernel.instance_method(:object_id).bind(self).call
    end

    def class
      ::Kernel.instance_method(:class).bind(self).call
    end

    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)} properties=#{to_h.inspect}>"
    end
    alias_method :to_s, :inspect
  end
end
