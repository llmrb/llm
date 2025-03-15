# frozen_string_literal: true

require "llm"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include Module.new {
    def fixture(file)
      File.read File.join(fixtures, file)
    end

    def fixtures
      File.join(__dir__, "fixtures", "responses")
    end
  }
end
