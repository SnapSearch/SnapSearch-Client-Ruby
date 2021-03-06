require 'snap_search'
require 'rack/snap_search/config'

module Rack
    
    # Use to enable SnapSearch detection within your web application.
    class SnapSearch
        
        # Initialize the middleware.
        # 
        # @param [#call] app The Rack application.
        # @param [Hash, #to_h] options Options to configure this middleware with.
        # @yield [Rack::SnapSearch::Config, SnapSearch::Detector] A block to further modify the middleware.
        # @yieldparam [Rack::SnapSearch::Config] config Options to configure this middleware with, optionally preset with the `options` param.
        # @yieldparam [SnapSearch::Detector] detector The instance of the Detector class which will be used for detecting whether requests are coming from a robot.
        def initialize(app, options={}, &block)
            raise TypeError, 'app must respond to #call' unless app.respond_to?(:call)
            raise TypeError, 'options must be a Hash or respond to #to_h or #to_hash' unless options.is_a?(Hash) || options.respond_to?(:to_h)    || options.respond_to?(:to_hash)
            options = options.to_h rescue options.to_hash
            
            @app = app
            
            setup_config(options)
            
            block.call(@config) if block_given?
            
            setup_client
            setup_detector
            setup_interceptor
        end
        
        # Run the middleware.
        # 
        # @param [Hash, to_h] app The Rack environment
        def call(environment)
            raise TypeError, 'environment must be a Hash or respond to #to_h or #to_hash' unless environment.is_a?(Hash) || environment.respond_to?(:to_h)    || environment.respond_to?(:to_hash)
            environment = environment.to_h rescue environment.to_hash
            
            setup_x_forwarded_proto(environment) if @config.x_forwarded_proto
            
            setup_api_response_from_environment(environment) # Will set @api_response if one is given from the API
            
            if @api_response
              unless @config.response_callback.nil?
                @callback_response = @config.response_callback.call(*@api_response)
                
                setup_attributes_from_callback_response
              else
                setup_attributes_from_api_response
              end
              
              rack_response
            else
              setup_attributes_from_app(environment)
            end
            
            
        end
        
        protected
        
        # == Initialization Helpers
        
        # Setup the Config instance from the given options.
        def setup_config(options)
            @config = Rack::SnapSearch::Config.new(options)
            
            @config.x_forwarded_proto ||= true
        end
        
        # Setup the Client instance from the @config.
        def setup_client
            @client = ::SnapSearch::Client.new(
                email:          @config.email,
                key:            @config.key,
                parameters:     @config.parameters,
                api_url:        @config.api_url,
                ca_cert_file:   @config.ca_cert_file
            )
        end
        
        # Setup the Detector instance from the @config.
        def setup_detector
            @detector = ::SnapSearch::Detector.new(
                matched_routes:     @config.matched_routes,
                ignored_routes:     @config.ignored_routes,
                robots_json:        @config.robots_json,
                extensions_json:    @config.extensions_json,
                check_file_extensions: @config.check_file_extensions
            )
        end
        
        # Setup the Interceptor instance using the @client and @detector, then setup callbacks if needed.
        def setup_interceptor
            @interceptor = ::SnapSearch::Interceptor.new(@client, @detector)
            
            @interceptor.before_intercept(&@config.before_intercept) unless @config.before_intercept.nil?
            @interceptor.after_intercept(&@config.after_intercept) unless @config.before_intercept.nil?
        end
        
        # == Running Helpers
        
        # Alter the environment if the X-FORWARDED-PROTO header is given.
        def setup_x_forwarded_proto(environment)
            # Check X-Forwarded-Proto because Heroku SSL Support terminates at the load balancer
            if environment['X-FORWARDED-PROTO']
                environment['HTTPS'] = true && environment['rack.url_scheme'] = 'https' && environment['SERVER_PORT'] = 443 if environment['X-FORWARDED-PROTO'] == 'https'
                environment['HTTPS'] = false && environment['rack.url_scheme'] = 'http' && environment['SERVER_PORT'] = 80 if env['X-FORWARDED-PROTO'] == 'http'
            end
        end
        
        # Intercept and return the response.
        def setup_api_response_from_environment(environment)
            begin
                request = Rack::Request.new(environment.to_h)
                @api_response = @interceptor.intercept(request: request)
            rescue ::SnapSearch::Error => exception
                @config.on_exception.nil? ? raise(exception) : @config.on_exception.call(exception)
            end
        end
        
        # Setup the Location header in the response.
        def setup_location_header
            response_location_header = @api_response['headers'].find { |header| header['name'] == 'Location' }
            
            @headers['Location'] = response_location_header['value'] unless response_location_header.nil?
        end
        
        # Setup the Status header and body in the response.
        def setup_status_and_body
            @status, @body = @api_response['status'], [ @api_response['html'] ] # Note that the body in the Rack response must be an interable containing Strings, we it's wrapped within an Array.
        end
        
        # Setup Location and Status headers, as well as teh body, if we got a response from SnapSearch.
        def setup_attributes_from_api_response
            setup_location_header
            # TODO: Should setup_content_length_header?
            setup_status_and_body
        end
        
        def setup_attributes_from_app(environment)
          @status, @headers, @body = @app.call(environment)
        end
        
        def setup_attributes_from_callback_response
          @status, @headers, @body = @callback_response
          
          # Convert the Array of Hashes into a single Hash:
          @headers = @headers.each_with_object({}) { |hash, memo| memo[ hash.first[0] ] = hash.first[1] }
        end
        
        def rack_response
          [ @status, @headers, @body ]
        end
        
    end
    
end
