# frozen_string_literal: true

module LLM
  ##
  # The {LLM::Response::FileList LLM::Response::FileList} class represents a
  # list of file objects that are returned by a provider. It is an Enumerable
  # object, and can be used to iterate over the file objects in a way that is
  # similar to an array. Each element is an instance of LLM::Object.
  class Response::FileList < Response
    include Enumerable

    attr_accessor :files

    def each(&)
      @files.each(&)
    end
  end
end
