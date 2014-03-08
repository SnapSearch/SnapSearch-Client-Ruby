module SnapSearch
    
    # This handles callbacks for before and after interception of a robot.
    class Interceptor
        
        # Create a new Interceptor instance.
        # 
        # @param [Client] client The client to send HTTP requests to the SnapChat API with.
        # @param [Detector] detector The detector to detect and intercept robots with.
        def initialize(client, detector)
            @client, @detector = client, detector
        end
        
        # Begins the detection and returns the snapshot if the request was scraped.
        # 
        # @param [Hash, #to_h] options The options to pass to the Detector.
        # @return [Hash, false] The response from SnapSearch or `false`.
        def intercept(options={})
            encoded_url = @detector.get_encoded_url( options[:request].params, Addressable::URI.parse(options[:request].url) )
            
            # all the before interceptor and return an Hash response if it has one
            unless @before_intercept.nil?
                result = @before_intercept.call(encoded_url)
                
                return result.to_hash if !result.nil? && (result.respond_to?(:to_h) || result.respond_to?(:to_hash))
            end
            response = @detector.detect(options) ? @client.request(encoded_url) : false
            
            # call the after response interceptor, and pass in the response Hash (which is always going to be a Hash)
            @after_intercept.call(encoded_url, response) unless @after_intercept.nil?
            
            response
        end
        
        # Before intercept callback.
        # This is intended for client side caching. It can be used for requesting a client cached resource.
        # However it can also be used for other purposes such as logging.
        # The callable should accept a string parameter which will the current URL that is being requested.
        # If the callable returns a Hash, the Hash will be used as the returned response for Interceptor#intercept
        # 
        # @yield [url] Block to be executed before interception
        # @yieldparam [String] url The encoded URL of the request
        # @return [Interceptor] This instance
        def before_intercept(&block)
            @before_intercept = block if block_given?
            
            self
        end
        
        # After intercept callback.
        # This is intended for client side caching or as an alternative way to respond to interception when integrated into middleware stacks.
        # However it can also be used for other purposes such as logging.
        # 
        # @yield [url] Block to be executed after interception
        # @yieldparam [String] url The encoded URL of the request
        # @yieldparam [Hash] response The snapshot response
        # @return [Interceptor] This instance
        def after_intercept(&block)
            @after_intercept = block if block_given?
            
            self
        end
        
    end
    
end
