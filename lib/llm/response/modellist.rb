# frozen_string_literal: true

module LLM
  ##
  # The {LLM::Response::ModelList LLM::Response::ModelList} class represents a
  # list of model objects that are returned by a provider. It is an Enumerable
  # object, and can be used to iterate over the model objects in a way that is
  # similar to an array. Each element is an instance of OpenStruct.
  class Response::ModelList < Response
    include Enumerable

    attr_accessor :models

    def each(&)
      @models.each(&)
    end
  end
end
