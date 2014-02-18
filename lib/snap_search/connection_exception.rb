require 'snap_search/exception'

module SnapSearch
    
    # Raised when the Client could not connect to the client's `api_url`.
    class ConnectionException < Exception
        
        # Create a new ConnectionException.
        def initialize
            super('Could not establish a connection to SnapSearch.')
        end
        
    end
    
end
