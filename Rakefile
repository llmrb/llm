# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

desc "Run linter"
task :rubocop do
  sh "bundle exec rubocop"
end

desc "Run tests"
task :spec do
  sh "bundle exec rspec"
end

namespace :spec do
  cassettes = File.join(__dir__, "spec", "fixtures", "cassettes")
  remotes = %w[openai gemini anthropic deepseek]
  locals = %w[ollama llamacpp]

  namespace :remote do
    desc "Clear remote cassette cache"
    task :clear do
      remotes.each { rm_rf File.join(cassettes, _1) }
    end
  end

  namespace :local do
    desc "Clear local cassette cache"
    task :clear do
      locals.each { rm_rf File.join(cassettes, _1) }
    end
  end
end

task default: %i[spec rubocop]
