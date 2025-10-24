# frozen_string_literal: true

class LLM::Tool
  ##
  # The {LLM::Tool::Param LLM::Tool::Param} class extends the
  # {LLM::Tool LLM::Tool} class with a "param" method that can
  # define a parameter for simple types. For complex types, use
  # {LLM::Tool.params LLM::Tool.params} instead.
  #
  # @example
  #   class Greeter < LLM::Tool
  #     name "greeter"
  #     description "Greets the user"
  #     param :name, String, "The user's name", required: true
  #
  #     def call(name:)
  #       puts "Hello, #{name}!"
  #     end
  #   end
  module Param
    ##
    # @param name [Symbol]
    #   The name of a parameter
    # @param type [Class, Symbol]
    #   The parameter type (eg String)
    # @param description [String]
    #   The description of a property
    # @param options [Hash]
    #   A hash of options for the parameter
    # @option options [Boolean] :required
    #   Whether or not the parameter is required
    # @option options [Object] :default
    #   The default value for a given property
    # @option options [Array<String>] :enum
    #   One or more possible values for a param
    def param(name, type, description, options = {})
      lock do
        function.params do |schema|
          leaf = schema.public_send(Utils.resolve(type))
          leaf = Utils.setup(leaf, description, options)
          schema.object(name => leaf)
        end
      end
    end

    ##
    # @api private
    module Utils
      extend self

      def resolve(type)
        case type
        when String then :string
        when Integer then :integer
        when Float then :number
        else type
        end
      end

      def setup(leaf, description, options)
        required = options.fetch(:required, false)
        default = options.fetch(:default, nil)
        enum = options.fetch(:enum, nil)
        leaf.required if required
        leaf.description(description) if description
        leaf.default(default) if default
        leaf.enum(enum) if enum
        leaf
      end
    end
  end
end