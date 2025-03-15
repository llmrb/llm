# frozen_string_literal: true

require "webmock"
require "json"

WebMock.enable!
WebMock.disable_net_connect!
WebMock.stub_request(:post, "https://api.openai.com/v1/chat/completions")
  .with(headers: {"Content-Type" => "application/json"})
  .to_return(
    status: 200,
    headers: {"Content-Type" => "application/json"},
    body: JSON.dump(
      {
        "id" => "chatcmpl-ARnnax792su04fapiLQ1EMZlIPR9N",
        "object" => "chat.completion",
        "created" => 1_731_189_646,
        "model" => "gpt-4o-mini-2024-07-18",
        "choices" => [
          {
            "index" => 0,
            "message" => {
              "role" => "assistant",
              "content" => "The sky is typically blue during the day, but it can have beautiful\n" \
                           "hues of pink, orange, and purple during sunset! As for an orange,\n" \
                           "it's typically orange in color - funny how that works, right?\n" \
                           "I love Ruby too! Did you know that a Ruby is not only a beautiful\n" \
                           "gemstone, but it's also a programming language that's both elegant\n" \
                           "and powerful! Speaking of colors, why did the orange stop?\n" \
                           "Because it ran out of juice!",
              "refusal" => nil
            },
            "logprobs" => nil,
            "finish_reason" => "stop"
          }
        ],
        "usage" => {
          "prompt_tokens" => 25_549,
          "completion_tokens" => 63,
          "total_tokens" => 25_612,
          "prompt_tokens_details" => {"cached_tokens" => 0, "audio_tokens" => 0},
          "completion_tokens_details" => {
            "reasoning_tokens" => 0, "audio_tokens" => 0,
            "accepted_prediction_tokens" => 0, "rejected_prediction_tokens" => 0
          }
        },
        "system_fingerprint" => "fp_9b78b61c52"
      }
    )
  )
