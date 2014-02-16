require 'pathname'
require 'json'
require 'addressable/uri'

module SnapSearch
  
  # This is used to detect if an incoming request to a HTTP server is coming from a robot.
  class Detector
    
    attr_reader :matched_routes, :ignored_routes, :check_static_files
    
    # Create a new Detector instance.
    # 
    # @param [Hash, #to_h] options The options to create the detector with.
    # @option options [Array<Regexp>] :matched_routes The whitelisted routes.
    # @option options [Array<Regexp>] :ignored_routes The blacklisted routes.
    # @option options [String, #to_s] :robots_json The path of the JSON file containing the user agent whitelist & blacklist.
    # @option options [true, false] :check_static_files Set to `true` to ignore direct requests to files.
    # @option options [Rack::Request] :request The Rack request that is to be checked/detected.
    def initialize(options={})
      options = {
        matched_routes: [],
        ignored_routes: [],
        robots_json: Pathname.new(__FILE__).join('..', '..', '..', 'data', 'robots.json').to_s,
        check_static_files: false
      }.merge(options)
      
      @matched_routes, @ignored_routes, @check_static_files = options.values_at(:matched_routes, :ignored_routes, :check_static_files)
      
      @robots = parse_robots_json(@robots_json)
    end
    
    # Detects if the request came from a search engine robot. It will intercept in cascading order:
    #   1. on a GET request
    #   2. on an HTTP or HTTPS protocol
    #   3. not on any ignored robot user agents
    #   4. not on any route not matching the whitelist
    #   5. not on any route matching the blacklist
    #   6. not on any static files that is not a PHP file if it is detected
    #   7. on requests with _escaped_fragment_ query parameter
    #   8. on any matched robot user agents
    # 
    # @return [true, false] If the request came from a robot
    def detect
      real_path = get_decoded_path
      document_root = @request['DOCUMENT_ROOT']
      
      # only intercept on get requests, SnapSearch robot cannot submit a POST, PUT or DELETE request
      return false unless request.get?
      
      # only intercept on http or https protocols
      return false unless %W[http https].include?(request.scheme)
      
      # detect ignored user agents, if true, then return false
      return false if request.user_agent =~ /#{ @robots['ignore'].collect { |user_agent| Regexp.escape(user_agent) }.join(?|) }/i
      
      # if the requested route doesn't match any of the whitelisted routes, then the request is ignored
      # of course this only runs if there are any routes on the whitelist
      return false if !matched_routes.empty? && !matched_routes.all? { |route| real_path =~ route }
      
      # detect ignored routes
      return false if ignored_routes.any? { |route| real_path =~ route }
      
      # ignore direct requests to files unless it's a php file
      if check_static_files && !document_root.empty? && !real_path.empty?
        
        # convert slashes to OS specific slashes
        # remove the trailing / or \ from the document root if it exists
        document_root = document_root.gsub!(/[\\\/]/, File::SEPARATOR)
        document_root.gsub!(/#{Regexp.escape(File::SEPARATOR)}$/, '')
        
        # convert slashes to OS specific slashes
        # remove the leading / or \ from the path if it exists
        real_path = real_path.gsub!(/[\\\/]/, File::SEPARATOR)
        real_path.gsub!(/^#{Regexp.escape(File::SEPARATOR)}/, '')
        
        absolute_path = Pathname.new(document_root).join(real_path)
        
        return false if absolute_path.exist? && absolute_path.extname != 'php'
      end
      
      # detect escaped fragment (since the ignored user agents has been already been detected, SnapSearch won't continue the interception loop)
      return true if request.params.has_key?('_escaped_fragment_')
      
      # detect matched robots, if true, then return true
      return true if request.user_agent =~ /#{ @robots['match'].collect { |user_agent| Regexp.escape(user_agent) }.join(?|) }/i
      
      # if no match at all, return false
      false
    end
    
    # Sets a matched or ignored robots array. This replaces the matched or ignored arrays from Robots.json
    # 
    # @param robots [Array<String>] Array of robots user agents
    # @param type [true, false] Type can be 'ignore' or 'match'
    # @return [true, false] 
    def set_robots(robots, type=nil)
      unless type.nil?
        return false unless %W{ignore match}.include?(type)
        
        @robots[type] = robots
      else
        @robots = robots
      end
      
      true
    end
    
    # Adds a single robot or an array of robots to the matched robots in Robots.json
    # 
    # @param robots [String, Array<String>] String of single or array of multiple robot user agent(s)
    def add_match_robots(robots)
      # NOTE: This method is redundant. One could simply do `detector.robots['match'] += ['SomeAgent']` or `detector.robots['match'] << "SomeAgent"`
      # TODO: Validate that robots is Array (of Strings) or String
      if robots.is_a?(Array)
        @robots['match'] += robots
      else
        @robots['match'] << robots
      end
    end
    
    # Adds a single robot or an array of robots to the ignored robots in Robots.json
    # 
    # @param robots [String, Array<String>] String of single or array of multiple robot user agent(s)
    def add_ignore_robots(robots)
      # NOTE: This method is redundant. One could simply do `detector.robots['ignore'] += ['SomeAgent']` or `detector.robots['match'] << "SomeAgent"`
      # TODO: Validate that robots is Array (of Strings) or String
      if robots.is_a?(Array)
        @robots['ignore'] += robots
      else
        @robots['ignore'] << robots
      end
    end
    
    # Gets the encoded URL that is passed to SnapSearch so that SnapSearch can scrape the encoded URL.
    # If _escaped_fragment_ query parameter is used, this is converted back to a hash fragment URL.
    # 
    # @return [String] URL intended for SnapSearch
    def get_encoded_url
      if request.params.has_key?('_escaped_fragment_')
        qs_and_hash = get_real_qs_and_hash_fragment(true)
        url = (@request.base_url + @request.path).gsub(/\?.*$/, '')
        
        url + qs_and_hash['qs'] + qs_and_hash['hash']
      else
        @request.url
      end
    end
    
    # Gets the decoded URL path relevant for detecting matched or ignored routes during detection.
    # It is also used for static file detection.
    # 
    # @return [String] The decoded URL
    def get_decoded_path
      if request.params.has_key?('_escaped_fragment_')
        qs_and_hash = get_real_qs_and_hash_fragment(false)
        url = (@request.base_url + @request.path).gsub(/\?.*$/, '')
        
        url + qs_and_hash['qs'] + qs_and_hash['hash']
      else
        CGI.unescape(@request.path)
      end
    end
    
    # Gets the real query string and hash fragment by reversing the Google's _escaped_fragment_ protocol to the hash bang mode.
    # Google will convert the original url from:
    # http://example.com/path#!key=value to http://example.com/path?_escaped_fragment_=key%26value
    # Therefore we have to reverse this process to the original url which will be used for snapshotting purposes.
    # https://developers.google.com/webmasters/ajax-crawling/docs/specification
    # This is used for both getting the encoded url for scraping and the decoded path for detection.
    # 
    # @param [true, false] encode Whether to CGI.escape the query string or not
    # @return [Hash] Hash of query string and hash fragment
    def get_real_qs_and_hash_fragment(escape)
      query_parameters = @request.params.dup
      query_parameters.delete('_escaped_fragment_')
      query_parameters = query_parameters.to_a
      
      query_string = ''
      unless query_parameters.empty?
        query_parameters.collect! { |key, value| [ CGI.escape(key), CGI.escape(value) ] } if escape
        query_parameters.collect! { |key, value| "#{key}=#{value}" }
        
        query_string = "?#{ query_parameters.join(?&) }"
      end
      
      hash = @request.params['_escaped_fragment_']
      hash_string = ''
      hash_string = "#!#{hash}" unless hash.nil?
      
      {
        'qs' => query_string,
        'hash'  => hash_string
      }
    end
    
    # Parses the Robots.json file by decoding the JSON and throwing an exception if the decoding went wrong.
    # 
    # @param  [String] robots_json Absolute path to Robots.json
    # @return [Hash<String, Array<String>>] The JSON data
    def parse_robots_json(robots_json)
      JSON.parse( File.read(robots_json.to_s) ) # Ruby raises it's own generic I/O read errors & JSON errors
    end
    
  end
  
end
