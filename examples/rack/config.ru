# Notes to run:
#     gem install bundler
#     bundle install
#     rackup
# 
# Testing:
#    Visit http://localhost:9292/
#    Visit http://localhost:9292/?_escaped_fragment_

require 'bundler/setup'
require 'rack/snap_search'

use Rack::Static, urls: ['/img', '/js', '/css'], root: 'public'

use Rack::SnapSearch do |config|
    config.email = 'email'
    config.key = 'password'
    config.on_exception do |exception|
        p exception
    end
end

class Application
    
    def call(env)
        headers = {
            'Content-Type'    => 'text/html',
            'Cache-Control' => 'public, max-age=86400'
        }
        body = File.read('public/index.html')
        
        [ 200, headers, [body] ]
    end
    
end

run Application.new
