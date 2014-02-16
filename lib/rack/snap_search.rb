require 'snap_search'
require 'rack/snap_search/config'

module Rack
  
  # TODO: YARD
  class SnapSearch
    
    # TODO: YARD
    def initialize(app, options={}, &block)
      @app, @config = app, Rack::SnapSearch::Config.new(options)
      
      detector = ::SnapSearch::Detector.new
      
      block.call(@config, detector) if block_given?
      
      client = ::SnapSearch::Client.new( email: @config.email, key: @config.key )
      @interceptor = ::SnapSearch::Interceptor.new(client, detector)
    end
    
    # TODO: YARD
    def call(environment)
      @status, @headers, @body = @app.call(environment)
      @request = Rack::Request.new(environment)
      
      setup_response
      setup_attributes if @response
      
      [ @status, @headers, @body ]
    end
    
    protected
    
    # TODO: YARD
    def setup_response
      @response = begin
        @interceptor.intercept(request: @request) # TODO: ignored_routes, matched_routes, robots_json, & check_static_files options
      rescue SnapSearch::Exception => exception
        @config.on_exception.call(exception) unless @config.on_exception.nil?
      end
    end
    
    # TODO: YARD
    def setup_location_header
      response_location_header = @response.headers.find { |header| header['name'] == 'Location' }
      
      @headers['Location'] = response_location_header['value'] unless response_location_header.nil?
    end
    
    # TODO: YARD
    def setup_status_and_body
      @status, @body = @response.status, @response.body # TODO: Need to status.to_i?
    end
    
    # TODO: YARD
    # this request is from a robot
    def setup_attributes_if_response_exists
      setup_location_header
      # TODO: Should setup_content_length_header ??
      setup_status_and_body
    end
    
  end
  
end
