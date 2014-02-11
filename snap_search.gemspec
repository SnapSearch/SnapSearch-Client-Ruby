require 'pathname'

Gem::Specification.new do |s|
  
  # Variables
  s.author      = 'Polycadamy'
  s.email       = '' # TODO
  s.summary     = '' # TODO
  s.license     = 'MIT'
  
  # Dependencies
  s.add_dependency 'version',                 '~> 1.0.0'
  s.add_dependency 'httpi',                   '~> 2.1.0'
  s.add_development_dependency 'rspec',       '~> 2.14.1'
  s.add_development_dependency 'guard-rspec', '~> 4.2.5'
  s.add_development_dependency 'fuubar',      '~> 1.3.2'
  
  # Pragmatically set variables
  s.homepage      = "http://github.com/RyanScottLewis/#{s.name}" # TODO: Real homepage
  s.version       = Pathname.glob('VERSION*').first.read rescue '0.0.0'
  s.description   = s.summary
  s.name          = Pathname.new(__FILE__).basename('.gemspec').to_s
  s.require_paths = ['lib']
  s.files         = Dir['{{Rake,Gem}file{.lock,},README*,VERSION,LICENSE,*.gemspec,{lib,bin,examples,spec,test}/**/*}']
  s.test_files    = Dir['{examples,spec,test}/**/*']
  
end
