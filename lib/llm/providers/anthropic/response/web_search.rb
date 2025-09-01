# frozen_string_literal: true

module LLM::Anthropic::Response
  ##
  # The {LLM::Anthropic::Response::WebSearch LLM::Anthropic::Response::WebSearch}
  # module provides methods for accessing web search results from a web search
  # tool call made via the {LLM::Provider#web_search LLM::Provider#web_search}
  # method.
  module WebSearch
    ##
    # Returns one or more search results
    # @return [Array<LLM::Object>]
    def search_results
      LLM::Object.from_hash(
        content
          .select { _1["type"] == "web_search_tool_result" }
          .flat_map { |n| n.content.map { _1.slice(:title, :url) } }
      )
    end
  end
end
