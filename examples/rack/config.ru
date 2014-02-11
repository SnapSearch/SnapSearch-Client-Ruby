require 'pathname'
$:.unshift( Pathname.new(__FILE__).join('..', '..', '..', 'lib').expand_path.to_s )
require 'rack/snap_search'

use Rack::Static, urls: ['/img', '/js', '/css'], root: 'public'

# use Rack::SnapSearch do |config|
#   config.email = 'email'
#   config.key = 'key'
#   config.on_exception do |exception|
#     p exception
#   end
# end

class Middleware
  
  def initialize(app)
    @app = app
  end
  
  def call(env)
    status, headers, body = @app.call(env)
    
    # TODO: REMOVE DEBUGGING
    puts ?! * 80
    p env
    puts ?! * 80
    
    [ status, headers, [body] ]
  end
  
end

use Middleware

class Application
  
  def call(env)
    headers = {
      'Content-Type'  => 'text/html',
      'Cache-Control' => 'public, max-age=86400'
    }
    body = File.read('public/index.html')
    
    [ 200, headers, body ]
  end
  
end

run Application.new
