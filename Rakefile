require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:stage) do |t|
  ENV['PLATFORM']='stage'
  t.pattern = 'spec/api/*_spec.rb'
end

RSpec::Core::RakeTask.new(:live) do |t|
  ENV['PLATFORM']='live'
  t.pattern = 'spec/api/*_spec.rb'
end

namespace :features do
  RSpec::Core::RakeTask.new(:test) do |t|
    ENV['PLATFORM']='stage'
    t.pattern = 'spec/cleric/*_spec.rb'
  end
end

task :default => :stage
