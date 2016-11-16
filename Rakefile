require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:stage_eu) do |t|
  t.ruby_opts = "-I lib:spec"
  ENV['PLATFORM']='stage'
  ENV['REGION']= 'eu'
  t.pattern = 'spec/api/*_spec.rb'
end

RSpec::Core::RakeTask.new(:stage_ap) do |t|
  t.ruby_opts = "-I lib:spec"
  ENV['PLATFORM']='stage'
  ENV['REGION']= 'ap'
  t.pattern = 'spec/api/*_spec.rb'
end

RSpec::Core::RakeTask.new(:stage_cn) do |t|
  t.ruby_opts = "-I lib:spec"
  ENV['PLATFORM']='stage'
  ENV['REGION']= 'cn'
  t.pattern = 'spec/api/*_spec.rb'
end

RSpec::Core::RakeTask.new(:live) do |t|
  t.ruby_opts = "-I lib:spec"
  ENV['PLATFORM']='live'
  t.pattern = 'spec/api/*_spec.rb'
end

namespace :features do
  RSpec::Core::RakeTask.new(:test) do |t|
    t.ruby_opts = "-I lib:spec"
    ENV['PLATFORM']='stage'
    t.pattern = 'spec/cleric/*_spec.rb'
  end
end

task :default => :stage_eu
