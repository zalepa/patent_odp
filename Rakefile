# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

# Auto-correct RuboCop offenses
RuboCop::RakeTask.new("rubocop:autocorrect") do |task|
  task.options = ["--autocorrect"]
end

# Auto-correct all RuboCop offenses (including unsafe)
RuboCop::RakeTask.new("rubocop:autocorrect_all") do |task|
  task.options = ["--autocorrect-all"]
end

task default: %i[spec rubocop]
