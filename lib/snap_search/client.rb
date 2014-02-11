require 'json'
require 'httpi'
require 'snap_search/connection_exception'
require 'snap_search/validation_exception'

module SnapSearch
  
  # TODO: YARD
  class Client
    
    attr_reader :email, :key, :parameters, :api_url
    
    # TODO: YARD
    def initialize(options={})
      initialize_attributes(options)
    end
    
    # TODO: YARD
    def email=(value)
      # TODO: Complain if value isnt a String/simple email validation
      @email = value
    end
    
    # TODO: YARD
    def key=(value)
      @key = value.nil? ? nil : value.to_s
    end
    
    # TODO: YARD
    def parameters=(value)
      # TODO: Complain if @parameters is not a Hash
      # TODO: Convert all keys to strings? Or does JSON do that for us?
      @parameters = value
    end
    
    # TODO: YARD
    def api_url=(value)
      # TODO: Complain if @api_url is not a String/simple URL validation
      @api_url = value
    end
    
    # TODO: YARD
    def request(url)
      # TODO: Complain if url is not a String/simple URL validation
      @parameters['url'] = url # The URL must contain the entire URL with the _escaped_fragment_ parsed out
      
      content_from_response(send_request)
    end
    
    protected
    
    # TODO: YARD
    def initialize_attributes(options)
      # TODO: Complain if options isnt a Hash
      
      options = {
        parameters: {},
        api_url: 'https://snapsearch.io/api/v1/robot'
      }.merge(options)
      
      self.email, self.key, self.parameters, self.api_url = options.values_at(:email, :key, :parameters, :api_url)
    end
    
    # Send an authenticated HTTP POST request encoded in JSON to the API URL
    # using the HTTP client adapter of the developer's choice.
    # 
    # @return [HTTPI::Response] The HTTP response object.
    def send_request
      request = HTTPI::Request.new
      request.url = api_url
      request.auth.basic(email, key)
      request.open_timeout = 30 # TODO: Have as option in initialize_attributes?
      request.body = parameters.to_json
      
      HTTPI.post(request)
    rescue
      raise ConnectionException
    end
    
    # TODO: YARD
    def content_from_response(response)
      body = JSON.parse(response.body)
      
      case body['code']
      when 'success' then body['content']
      when 'validation_error' then raise( ValidationException, body['content'] )
      else
        # TODO: Raise exception?
        # System error on SnapSearch; Nothing we can do
        false
      end
    end
    
  end
  
end
