require 'pathname'

Gem::Specification.new do |s|
  
  # Variables
  s.author      = 'Ryan Scott Lewis'
  s.email       = 'roger.qiu@polycademy.com'
  s.name        = 'snapsearch-client-ruby'
  s.summary     = 'Ruby HTTP Client Middleware Libraries for SnapSearch. Search engine optimisation for single page applications.'
  s.homepage    = 'https://github.com/SnapSearch/SnapSearch-Client-Ruby'
  s.license     = 'MIT'
  
  # Dependencies
  s.add_dependency 'version',                 '~> 1.0.0'
  s.add_dependency 'httpi',                   '~> 2.1.0'
  s.add_dependency 'addressable',             '~> 2.0.0'
  s.add_dependency 'rack',                    '~> 1.5.0'
  s.add_development_dependency 'rake',        '~> 10.1.1'
  s.add_development_dependency 'rspec',       '~> 2.14.1'
  s.add_development_dependency 'guard-rspec', '~> 4.2.5'
  s.add_development_dependency 'guard-yard',  '~> 2.1.0'
  s.add_development_dependency 'fuubar',      '~> 1.3.2'
  
  # Pragmatically set variables
  s.version       = Pathname.glob('VERSION*').first.read rescue '0.0.0'
  s.description   = s.summary
  s.require_paths = ['lib']
  s.files         = Dir['{{Rake,Gem}file{.lock,},README*,VERSION,LICENSE,*.gemspec,{lib,bin,examples,resources,spec,test}/**/*}']
  s.test_files    = Dir['{examples,spec,test}/**/*']
  
end
