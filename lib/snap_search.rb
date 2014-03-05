require 'pathname'

module SnapSearch
    
    def self.root
        @root ||= Pathname.new(__FILE__).join('..', '..').expand_path
    end
    
end

require 'snap_search/client'
require 'snap_search/detector'
require 'snap_search/interceptor'
require 'rack/snap_search'
