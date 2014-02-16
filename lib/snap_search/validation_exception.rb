require 'snap_search/exception'

module SnapSearch
  
  # Raised when the parameters of a request from the Client are not valid.
  class ValidationException < Exception
    
    # Raise a new ValidationException
    def initialize(response_content)
      error_messages = response_content.values.collect { |message| "  #{message}" }.join("\n")
      
      super("Validation error from SnapSearch. Check your request parameters:\n#{ error_messages }")
    end
    
  end
  
end
