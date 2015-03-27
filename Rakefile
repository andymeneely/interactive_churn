require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'yard'

task default: [:install, :spec]

RSpec::Core::RakeTask.new(:spec)

task doc: [:yarddoc]
YARD::Rake::YardocTask.new(:yarddoc) do |t|
  t.files = ['lib/**/*.rb']
end
