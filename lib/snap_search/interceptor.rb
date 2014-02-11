module SnapSearch
  
  # TODO: YARD
  # TODO: This class is the result of excessive abstraction and can be rolled into Client
  class Interceptor
    
    # TODO: YARD
    def initialize(client, detector)
      @client, @detector = client, detector
    end
    
    # Intercept begins the detection and returns the snapshot if the request was scraped.
    # 
    # @return [Hash, false] The response from SnapSearch or false
    def intercept(options={}) # TODO: YARD raises & arguments
      @detector.detect(options) ? @client.request( @detector.get_encoded_url ) : false
    end
    
  end
  
end
