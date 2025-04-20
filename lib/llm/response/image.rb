# frozen_string_literal: true

module LLM
  ##
  # The {LLM::Response::Image LLM::Response::Image} class represents
  # an image response. An image response might encapsulate one or more
  # URLs, or a base64 encoded image -- depending on the provider.
  class Response::Image < Response
    ##
    # Returns the content type (eg image/png)
    # @return [String]
    def mime_type
      parsed[:mime_type]
    end

    ##
    # Returns an image object
    # @return [OpenStruct]
    def image
      if encoded
        OpenStruct.from_hash(
          encoded:,
          binary: decoded
        )
      else
        nil
      end
    end

    ##
    # @return [Array<String>, nil]
    #  Returns one or more image URLs
    def urls
      parsed[:urls]
    end

    private

    ##
    # Returns a base64 encoded string
    # @return [String]
    def encoded
      parsed[:encoded]
    end

    ##
    # Returns the image as a binary string
    # @return [String]
    def decoded
      encoded.unpack1("m0")
    end

    def parsed
      @parsed ||= parse_image(body)
    end
  end
end
