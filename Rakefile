require 'rubygems'
require 'rake/testtask'
require 'bundler/gem_tasks'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "Indirizzo"
  gem.homepage = "http://github.com/daveworth/indirizzo"
  gem.license = "LGPL"
  gem.summary = %Q{Indirizzo is simply an extraction of the US Street Address parsing code from Geocoder::US}
  gem.description = %Q{Indirizzo is simply an extraction of the US Street Address parsing code from Geocoder::US}
  gem.email = "dave@highgroove.com"
  gem.authors = ["Dave Worth"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  gem.add_development_dependency 'awesome_print'
  gem.add_development_dependency 'cover_me'
end
Jeweler::RubygemsDotOrgTasks.new

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

namespace :cover_me do
  desc "Generates and opens code coverage report."
  task :report do
    require 'cover_me'
    CoverMe.complete!
  end
end

task :test do
  Rake::Task['cover_me:report'].invoke
end
