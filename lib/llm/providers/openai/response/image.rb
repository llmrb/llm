# frozen_string_literal: true

module LLM::OpenAI::Response
  module Image
    def urls
      data.filter_map { _1["url"] }
    end

    def images
      data.filter_map do
        next unless _1["b64_json"]
        StringIO.new(_1["b64_json"].unpack1("m0"))
      end
    end
  end
end
