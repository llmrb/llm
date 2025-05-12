# frozen_string_literal: true

module LLM
  ##
  # The {LLM::Response::Image LLM::Response::Image} class represents
  # an image response. An image response might encapsulate one or more
  # URLs, or a base64 encoded image -- depending on the provider.
  class Response::Image < Response
    ##
    # Returns one or more image objects, or nil
    # @return [Array<LLM::Object>, nil]
    def images
      parsed[:images].any? ? parsed[:images] : nil
    end

    ##
    # Returns one or more image URLs, or nil
    # @return [Array<String>, nil]
    def urls
      parsed[:urls].any? ? parsed[:urls] : nil
    end

    private

    def parsed
      @parsed ||= parse_image(body)
    end
  end
end
