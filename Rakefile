# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

desc "Run tests"
task :spec do
  sh "bundle exec rspec"
end

desc "Run linter"
task :rubocop do
  sh "bundle exec rubocop"
end
task default: %i[spec rubocop]
