require 'snap_search/exception'

module SnapSearch
  
  # TODO: YARD
  class ConnectionException < Exception
    
    # TODO: YARD
    def initialize
      super('Could not establish a connection to SnapSearch.')
    end
    
  end
  
end
