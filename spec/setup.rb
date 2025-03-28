# frozen_string_literal: true

require "llm"
require "webmock/rspec"
require "vcr"

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data("TOKEN") { ENV["LLM_SECRET"] }
end
