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
            @detector.detect(options) ? @client.request(encoded_url) : false
        end
        
    end
    
end
