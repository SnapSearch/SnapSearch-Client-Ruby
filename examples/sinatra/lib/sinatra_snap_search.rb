require 'bundler/setup'
require 'sinatra/base'
require 'pathname'
require 'snap_search'

class SinatraSnapSearch < Sinatra::Base
  
  configure do
    set :root, SnapSearch.root.join('examples', 'sinatra')
    enable :sessions, :logging, :method_override, :static
    
    use Rack::SnapSearch do |config|
      
        # Required: The email to authenticate with.
        config.email = 'user@example.com'
        
        # Required: The key to authenticate with.
        config.key = 'API_KEY_HERE'
        
        # Optional: The API URL to send requests to.
        config.api_url = 'https://snapsearch.io/api/v1/robot' # Default
        
        # Optional: The CA Cert file to use when sending HTTPS requests to the API.
        config.ca_cert_file = SnapSearch.root.join('resources', 'cacert.pem') # Default
        
        # Optional: Check X-Forwarded-Proto because Heroku SSL Support terminates at the load balancer.
        config.x_forwarded_proto = true # Default
        
        # Optional: Extra parameters to send to the API.
        config.parameters = {} # Default
        
        # Optional: Whitelisted routes. Should be an Array of Regexp instances.
        config.matched_routes = [] # Default
        
        # Optional: Blacklisted routes. Should be an Array of Regexp instances.
        config.ignored_routes = [] # Default
        
        # Optional: A path of the JSON file containing the user agent whitelist & blacklist.
        config.robots_json = SnapSearch.root.join('resources', 'robots.json') # Default
        
        # Optional: A path to the JSON file containing a single Hash with the keys `ignore` and `match`. These keys contain Arrays of Strings (user agents)
        config.extensions_json = SnapSearch.root.join('resources', 'extensions.json') # Default
        
        # Optional: Set to `true` to ignore direct requests to files.
        config.check_file_extensions = false # Default
        
        # Optional: A block to run when an exception occurs when making requests to the API.
        config.on_exception do |exception|
            p exception
        end
        
        # Optional: A block to run before the interception of a bot.
        config.before_intercept do |url|
            puts "Before interception\n  URL: #{url}"
        end
        
        # Optional: A block to run after the interception of a bot.
        config.after_intercept do |url, response|
            puts "After interception\n  URL: #{url}\n  Response: #{response}"
        end
        
        # Optional: A block to manipulate the response from the SnapSearch API if a bit is intercepted.
        config.response_callback do |status, headers, body|
            puts "Response callback\n  Status: #{status}\n  Headers: #{headers}\n  Body: #{body}"
            
            [ status, headers, body ]
        end
        
    end
    
  end
  
  get '/' do
    redirect to('/index.html')
  end
  
end
