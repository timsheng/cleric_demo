require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:stage) do |t|
  ENV['PLATFORM']='stage'
  t.rspec_opts = "--pattern spec/api/*_spec.rb"
end

RSpec::Core::RakeTask.new(:live) do |t|
  ENV['PLATFORM']='live'
  t.rspec_opts = "--pattern spec/api/*_spec.rb"
end

task :default => :stage
