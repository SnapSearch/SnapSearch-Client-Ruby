require 'snap_search/error'

module SnapSearch
    
    # Raised when the Client could not connect to the client's `api_url`.
    class ConnectionError < Error
        
        # Create a new ConnectionError.
        def initialize
            super('Could not establish a connection to SnapSearch.')
        end
        
    end
    
end
