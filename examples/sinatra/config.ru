require 'pathname'
$:.unshift( Pathname.new(__FILE__).join('..', 'lib').expand_path.to_s )
require 'sinatra_snap_search'

run SinatraSnapSearch
