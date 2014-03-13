module Rack
    class SnapSearch
        
        # The configuration class for the Rack middleware.
        # Holds the attributes to initialize the Client, Interceptor, and Detector with.
        class Config
            
            ATTRIBUTES = [
                :email, :key, :api_url, :ca_cert_file, :x_forwarded_proto, :parameters,               # Client options
                :matched_routes, :ignored_routes, :robots_json, :extensions_json, :check_file_extensions # Detector options
            ]
            
            attr_accessor *ATTRIBUTES # Setup reader & writer instance methods for each attribute
            
            # Create a new instance.
            # 
            # @param [Hash] options The options to initialize this instance with.
            # @option options [String] :email The email to authenticate with.
            # @option options [String] :key The key to authenticate with.
            # @option options [String] :api_url The API URL to send requests to.
            # @option options [String] :ca_cert_file The CA Cert file to use when sending HTTPS requests to the API.
            # @option options [String] :x_forwarded_proto Check X-Forwarded-Proto because Heroku SSL Support terminates at the load balancer
            # @option options [String] :parameters Extra parameters to send to the API.
            # @option options [String] :matched_routes Whitelisted routes. Should be an Array of Regexp instances.
            # @option options [String] :ignored_routes Blacklisted routes. Should be an Array of Regexp instances.
            # @option options [String] :robots_json A path of the JSON file containing the user agent whitelist & blacklist.
            # @option options [String] :extensions_json A path to the JSON file containing a single Hash with the keys `ignore` and `match`. These keys contain Arrays of Strings (user agents)
            # @option options [String] :check_file_extensions Set to `true` to ignore direct requests to files.
            # @option options [Proc, #call] :on_exception The block to run when an exception within SnapSearch occurs.
            # @option options [Proc, #call] :before_intercept A block to run before the interception of a bot.
            # @option options [Proc, #call] :after_intercept A block to run after the interception of a bot.
            # @option options [Proc, #call] :response_callback A block to manipulate the response from the SnapSearch API.
            def initialize(options={})
                raise TypeError, 'options must be a Hash or respond to #to_h' unless options.is_a?(Hash) || options.respond_to?(:to_h) || options.respond_to?(:to_hash)
                options = options.to_h rescue options.to_hash
                
                ATTRIBUTES.each do |attribute|
                    send( "#{attribute}=", options[attribute] ) if options.has_key?(attribute)
                end
            end
            
            # Getter/Setter for the `on_exception` attribute.
            # 
            # @yield If given, the Proc or callable to set the attribute as.
            # @return [Proc] The value of the attribute.
            def on_exception(&block)
                @on_exception = block if block_given?
                
                @on_exception
            end
            
            # Getter/Setter for the `before_intercept` attribute on the Interceptor.
            # 
            # @yield If given, the Proc or callable to set the attribute as.
            # @return [Proc] The value of the attribute.
            def before_intercept(&block)
                @before_intercept = block if block_given?
                
                @before_intercept
            end
            
            # Getter/Setter for the `after_intercept` attribute on the Interceptor.
            # 
            # @yield If given, the Proc or callable to set the attribute as.
            # @return [Proc] The value of the attribute.
            def after_intercept(&block)
                @after_intercept = block if block_given?
                
                @after_intercept
            end
            
            # Getter/Setter for the `response_callback` attribute on the Interceptor.
            # 
            # @yield If given, the Proc or callable to set the attribute as.
            # @return [Proc] The value of the attribute.
            def response_callback(&block)
                @response_callback = block if block_given?
                
                @response_callback
            end
            
        end
        
    end
end
