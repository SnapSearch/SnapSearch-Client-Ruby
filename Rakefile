require 'bundler/setup'
require 'pathname'
require 'rake/version_task'
require 'rubygems/package_task'
require 'rspec/core/rake_task'

gemspec = Pathname.glob( Pathname.new(__FILE__).join('..', '*.gemspec') ).first
$spec = Gem::Specification.load( gemspec.to_s )

Gem::PackageTask.new($spec) do |task|
  task.need_zip = false
end

Rake::VersionTask.new do |task|
  task.with_git_tag = true
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec