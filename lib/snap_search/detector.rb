require 'pathname'
require 'json'
require 'addressable/uri'

module SnapSearch
  
  # This is used to detect if an incoming request to a HTTP server is coming from a robot.
  class Detector
    
    attr_reader :matched_routes, :ignored_routes, :check_static_files, :robots
    
    # Create a new Detector instance.
    # 
    # @param [Hash, #to_h] options The options to create the detector with.
    # @option options [Array<Regexp>] :matched_routes The whitelisted routes.
    # @option options [Array<Regexp>] :ignored_routes The blacklisted routes.
    # @option options [String, #to_s] :robots_json The path of the JSON file containing the user agent whitelist & blacklist.
    # @option options [true, false] :check_static_files Set to `true` to ignore direct requests to files.
    # @option options [Rack::Request] :request The Rack request that is to be checked/detected.
    def initialize(options={})
      # TODO: Validate options
      
      @options = {
        matched_routes: [],
        ignored_routes: [],
        robots_json: Pathname.new(__FILE__).join('..', '..', '..', 'data', 'robots.json').to_s,
        check_static_files: false
      }.merge(options) # Reverse merge: The hash `merge` is called on is used as the default and the options argument is merged into it
      
      @matched_routes, @ignored_routes, @check_static_files = options.values_at(:matched_routes, :ignored_routes, :check_static_files)
      
      self.robots_json = @options[:robots_json] # Use the setter method which sets the @robots_json instance variable to the path, then sets @robots to the parsed JSON of the path's contents.
    end
    
    # Parses the Robots.json file by decoding the JSON and throwing an exception if the decoding went wrong.
    # 
    # @param  [String] value Absolute path to the JSON file containing a single Hash with the keys `ignore` and `match`. These keys contain Arrays of Strings (user agents)
    def robots_json=(value)
      @robots_json = value.to_s
      @robots = JSON.parse( File.read(@robots_json) ) # Ruby raises it's own generic I/O read errors & JSON parse errors
      
      @robots_json
    end
    
    # Sets the list of robot user agents to match and ignore during detection.
    # Note that you must set `robots` to a Hash with the 'match' and 'ignore' keys, both containing Arrays
    # 
    # @param [Hash<String, Array<String>>] value The Hash containing the list of robot user agents to match and ignore.
    def robots=(value)
      raise TypeError, 'value must be a Hash' unless value.is_a?(Hash)
      
      @robots = { 'match' => [], 'ignore' => [], }.merge(@robots)
      
      @robots.each do |key, list|
        raise TypeError, "The '#{key}' must be an Array or respond to #to_a" unless list.is_a?(Array) || list.respond_to?(:to_a) # Validate all keys are Arrays or can be converted to one
        
        @robots[key] = list.to_a.collect(&:to_s) # Convert all values in the Arrays to Strings
      end
      
      @robots
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
    def detect(options={})
      options = {
        matched_routes: @matched_routes,
        ignored_routes: @ignored_routes,
        robots_json: @robots_json,
        check_static_files: false
      }.merge(options)
      
      # TODO: Validate the request key is given and is a Rack::Request
      self.robots_json = options[:robots_json] if options[:robots_json] != @robots_json # If a new robots_json path is given, use the custom setter method which will set @robots to that parsed JSON file
      
      uri = Addressable::URI.parse( options[:request].url )
      params = options[:request].params
      
      real_path = get_decoded_path(params, uri)
      document_root = options[:request]['DOCUMENT_ROOT']
      
      # only intercept on get requests, SnapSearch robot cannot submit a POST, PUT or DELETE request
      return false unless options[:request].get?
      
      # only intercept on http or https protocols
      return false unless %W[http https].include?(uri.scheme)
      
      # detect ignored user agents, if true, then return false
      return false if options[:request].user_agent =~ /#{ @robots['ignore'].collect { |user_agent| Regexp.escape(user_agent) }.join(?|) }/i
      
      # if the requested route doesn't match any of the whitelisted routes, then the request is ignored
      # of course this only runs if there are any routes on the whitelist
      return false if !options[:matched_routes].nil? && !options[:matched_routes].empty? && !options[:matched_routes].all? { |route| real_path =~ route }
      
      # detect ignored routes
      return false if !options[:ignored_routes].nil? && options[:ignored_routes].any? { |route| real_path =~ route }
      
      # ignore direct requests to files unless it's a php file
      if options[:check_static_files] && !document_root.empty? && !real_path.empty?
        
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
      return true if !uri.query_values.nil? && uri.query_values.has_key?('_escaped_fragment_')
      
      # detect matched robots, if true, then return true
      return true if options[:request].user_agent =~ /#{ @robots['match'].collect { |user_agent| Regexp.escape(user_agent) }.join(?|) }/i
      
      # if no match at all, return false
      false
    end
    
    # Gets the encoded URL that is passed to SnapSearch so that SnapSearch can scrape the encoded URL.
    # If _escaped_fragment_ query parameter is used, this is converted back to a hash fragment URL.
    # 
    # @param [Hash] params The parameters of the HTTP request.
    # @param [Addressable::URI] uri The Addressable::URI of the Rack::Request.
    # @return [String] URL intended for SnapSearch
    def get_encoded_url(params, uri)
      # TODO: Validate argument type
      # NOTE: Have to pass the Rack::Request instance and use the `request.params` method to retrieve the parameters because:
      #         uri.to_s         # => "http://localhost/snapsearch/path1?key1=value1&_escaped_fragment_=%2Fpath2%3Fkey2=value2"
      #         uri.query_values # => {"key1"=>"value1", "_escaped_fragment_"=>"/path2?key2"}
      #         request.params   # => {"key1"=>"value1", "_escaped_fragment_"=>"/path2?key2=value2"}
      #       Is seems Addressable screws up the spliting of params into a Hash, but Rack does not.
      if !uri.query_values.nil? && uri.query_values.has_key?('_escaped_fragment_')
        qs_and_hash = get_real_qs_and_hash_fragment(params, true) # TODO: Addressable does not correctly parse the query hash!
        url = "#{uri.scheme}://#{uri.authority}#{uri.path}" # Remove the query and fragment (SCHEME + AUTHORITY + PATH)... Addressable::URI encodes the uri
        
        url.to_s + qs_and_hash['qs'] + qs_and_hash['hash']
      else
        uri.to_s
      end
    end
    
    # Gets the decoded URL path relevant for detecting matched or ignored routes during detection.
    # It is also used for static file detection.
    # 
    # @param [Hash] params The parameters of the HTTP request.
    # @param [Addressable::URI] uri The Addressable::URI of the Rack::Request.
    # @return [String] The decoded URL.
    def get_decoded_path(params, uri)
      # TODO: Validate argument type
      # NOTE: Have to pass the Rack::Request instance and use the `request.params` method to retrieve the parameters because:
      #         uri.to_s         # => "http://localhost/snapsearch/path1?key1=value1&_escaped_fragment_=%2Fpath2%3Fkey2=value2"
      #         uri.query_values # => {"key1"=>"value1", "_escaped_fragment_"=>"/path2?key2"}
      #         request.params   # => {"key1"=>"value1", "_escaped_fragment_"=>"/path2?key2=value2"}
      #       Is seems Addressable screws up the spliting of params into a Hash, but Rack does not.
      if !uri.query_values.nil? && uri.query_values.has_key?('_escaped_fragment_')
        qs_and_hash = get_real_qs_and_hash_fragment(params, false) # TODO: Addressable does not correctly parse the query hash!
        
        Addressable::URI.unescape(uri.path) + qs_and_hash['qs'] + qs_and_hash['hash']
      else
        Addressable::URI.unescape(uri.path)
      end
    end
    
    # Gets the real query string and hash fragment by reversing the Google's _escaped_fragment_ protocol to the hash bang mode. 
    # This is used for both getting the encoded url for scraping and the decoded path for detection and is only called when the URI has a QUERY section.
    # 
    # Google will convert convert URLs like so:
    # Original URL: http://example.com/path1?key1=value1#!/path2?key2=value2
    # Original Structure: DOMAIN - PATH - QS - HASH BANG - HASH PATH - HASH QS
    # Search Engine URL: http://example.com/path1?key1=value1&_escaped_fragment_=%2Fpath2%3Fkey2=value2
    # Search Engine Structure: DOMAIN - PATH - QS - ESCAPED FRAGMENT
    # Everything after the hash bang will be stored as the _escaped_fragment_, even if they are query strings.
    # Therefore we have to reverse this process to get the original url which will be used for snapshotting purposes.
    # This means the original URL can have 2 query strings components.
    # The QS before the HASH BANG will be received by both the server and the client. However not all client side frameworks will process this QS.
    # The HASH QS will only be received by the client as anything after hash does not get sent to the server. Most client side frameworks will process this HASH QS.
    # See this for more information: https://developers.google.com/webmasters/ajax-crawling/docs/specification
    # 
    # @param [Hash] params The params from the URI of the request.
    # @param [true, false] encode Whether to Addressable::URI.escape the query string or not
    # @return [Hash] Hash of query string and hash fragment
    def get_real_qs_and_hash_fragment(params, escape)
      # TODO: Validate argument types
      query_params = params.dup
      query_params.delete('_escaped_fragment_')
      query_params = query_params.to_a
      
      query_string = ''
      unless query_params.empty?
        query_params.collect! { |key, value| [ Addressable::URI.escape(key), Addressable::URI.escape(value) ] } if escape
        query_params.collect! { |key, value| [ Addressable::URI.unescape(key), Addressable::URI.unescape(value) ] } unless escape
        query_params.collect! { |key, value| "#{key}=#{value}" }
        
        query_string = "?#{ query_params.join(?&) }"
      end
      
      hash_fragment = params['_escaped_fragment_']
      hash_fragment_string = ''
      hash_fragment_string = "#!#{hash_fragment}" unless hash_fragment.nil?
      
      {
        'qs' => query_string,
        'hash'  => hash_fragment_string
      }
    end
    
  end
  
end
