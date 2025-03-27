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
              "content" => "The answer to 5 + 15 is 20.\n" \
                           "The answer to (5 + 15) * 2 is 40.\n" \
                           "The answer to ((5 + 15) * 2) / 10 is 4.",
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
