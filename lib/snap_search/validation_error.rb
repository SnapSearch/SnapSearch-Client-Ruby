require 'snap_search/error'

module SnapSearch
    
    # Raised when the parameters of a request from the Client are not valid.
    class ValidationError < Error
        
        # Raise a new ValidationError
        def initialize(response_content)
            error_messages = response_content.values.collect { |message| "    #{message}" }.join("\n")
            
            super("Validation error from SnapSearch. Check your request parameters:\n#{ error_messages }")
        end
        
    end
    
end
