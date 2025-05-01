# frozen_string_literal: true

require "ostruct"
class OpenStruct
  module FromHash
    ##
    # @example
    #   obj = OpenStruct.from_hash(person: {name: 'John'})
    #   obj.person.name  # => 'John'
    #   obj.person.class # => OpenStruct
    # @param [Hash, Array] obj
    #   A Hash object
    # @return [OpenStruct]
    #   An OpenStruct object initialized by visiting `obj` with recursion
    def from_hash(obj)
      case obj
      when self then from_hash(obj.to_h)
      when Array then obj.map { |v| from_hash(v) }
      else
        visited = {}
        obj.each { visited[_1] = walk(_2) }
        new(visited)
      end
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
