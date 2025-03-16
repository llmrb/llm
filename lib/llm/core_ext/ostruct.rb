# frozen_string_literal: true

require "ostruct"
class OpenStruct
  module FromHash
    ##
    # @example
    #   obj = OpenStruct.from_hash(person: {name: 'John'})
    #   obj.person.name  # => 'John'
    #   obj.person.class # => OpenStruct
    # @param [Hash] hash_obj
    #   A Hash object
    # @return [OpenStruct]
    #   An OpenStruct object initialized by visiting `hash_obj` with
    #   recursion
    def from_hash(hash_obj)
      visited_object = {}
      hash_obj.each do |key, value|
        visited_object[key] = walk(value)
      end
      OpenStruct.new(visited_object)
    end

    private

    def walk(value)
      if Hash === value
        from_hash(value)
      elsif Array === value
        value.map { |v| (Hash === v) ? from_hash(v) : v }
      else
        value
      end
    end
  end
  extend FromHash
end
