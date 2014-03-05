require 'bundler/setup'
require 'sinatra/base'
require 'pathname'
require 'snap_search'

class SinatraSnapSearch < Sinatra::Base
  
  configure do
    set :root, SnapSearch.root.join('examples', 'sinatra')
    enable :sessions, :logging, :method_override, :static
    
    use Rack::SnapSearch, email: 'email', key: 'key'
  end
  
  get '/' do
    redirect to('/index.html')
  end
  
end
