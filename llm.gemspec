# frozen_string_literal: true

require_relative "lib/llm/version"

Gem::Specification.new do |spec|
  spec.name = "llm.rb"
  spec.version = LLM::VERSION
  spec.authors = ["Antar Azri", "0x1eef"]
  spec.email = ["azantar@proton.me", "0x1eef@proton.me"]

  spec.summary = "llm.rb is a lightweight Ruby library that provides a " \
                 "common interface and set of functionality for multple " \
                 "Large Language Models (LLMs). It is designed to be simple, " \
                 "flexible, and easy to use."
  spec.description = spec.summary
  spec.homepage = "https://github.com/llmrb/llm"
  spec.license = "0BSDL"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/llmrb/llm"

  spec.files = Dir[
    "README.md", "LICENSE.txt",
    "lib/*.rb", "lib/**/*.rb",
    "spec/*.rb", "spec/**/*.rb",
    "share/llm/models/*.yml", "llm.gemspec"
  ]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "webmock", "~> 3.24.0"
  spec.add_development_dependency "yard", "~> 0.9.37"
  spec.add_development_dependency "kramdown", "~> 2.4"
  spec.add_development_dependency "webrick", "~> 1.8"
  spec.add_development_dependency "test-cmd.rb", "~> 0.12.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "standard", "~> 1.40"
  spec.add_development_dependency "vcr", "~> 6.0"
end
