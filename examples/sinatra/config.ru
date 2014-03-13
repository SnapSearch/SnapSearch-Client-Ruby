# Notes to run:
#   gem install bundler
#   bundle install
#   rackup
# 
# Testing:
#   Visit http://localhost:9292/
#   Visit http://localhost:9292/?_escaped_fragment_

require 'bundler/setup'
require 'pathname'
$:.unshift( Pathname.new(__FILE__).join('..', 'lib').expand_path.to_s )
require 'sinatra_snap_search'

run SinatraSnapSearch
