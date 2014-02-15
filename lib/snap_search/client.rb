require 'json'
require 'httpi'
require 'snap_search/connection_exception'
require 'snap_search/validation_exception'

module SnapSearch
  
  # The Client sends an authenticated HTTP request to the SnapChat API and returns the `content`
  # field from the JSON response body.
  class Client
    
    attr_reader :email, :key, :parameters, :api_url
    
    # Create a new Client instance.
    # 
    # @param [Hash, #to_h] options The options to create the Client with.
    # @option options [String, #to_s] :email The email to authenticate with.
    # @option options [String, #to_s] :key The secret authentication key.
    # @option options [Hash, #to_h] :parameters ({}) The parameters to send with the HTTP request.
    # @option options [String, #to_s] :api_url (https://snapsearch.io/api/v1/robot) The URL to send the HTTP request to.
    def initialize(options={})
      initialize_attributes(options)
    end
    
    # Validate and set the value of the `email` attribute.
    # 
    # @param [String, #to_s] value The value to set the attribute to.
    # @return [String] The new value of the attribute.
    def email=(value)
      # TODO: Complain if value isn't a String/simple email validation
      @email = value
    end
    
    # Validate and set the value of the `key` attribute.
    # 
    # @param [String, #to_s] value The value to set the attribute to.
    # @return [String] The new value of the attribute.
    def key=(value)
      @key = value.nil? ? nil : value.to_s
    end
    
    # Validate and set the value of the `parameters` attribute.
    # 
    # @param [String, #to_s] value The value to set the attribute to.
    # @return [String] The new value of the attribute.
    def parameters=(value)
      # TODO: Complain if value is not a Hash
      # TODO: Convert all keys to strings? Or does JSON do that for us?
      @parameters = value
    end
    
    # Validate and set the value of the `api_url` attribute.
    # 
    # @param [String, #to_s] value The value to set the attribute to.
    # @return [String] The new value of the attribute.
    def api_url=(value)
      # TODO: Complain if @api_url is not a String/simple URL validation
      @api_url = value
    end
    
    # Send an authenticated HTTP request to the `api_url` and return the `content` field from the JSON response body.
    # 
    # @param [String, #to_s] url The url to send in the parameters to the `api_url`.
    # @return [String] The `content` field from the JSON response body.
    def request(url)
      # TODO: Complain if url is not a String/simple URL validation
      @parameters['url'] = url # The URL must contain the entire URL with the _escaped_fragment_ parsed out
      
      content_from_response(send_request)
    end
    
    protected
    
    # Initialize this instance based on options passed.
    # 
    # @param [Hash, #to_h] options The options to create the Client with.
    # @option options [String, #to_s] :email The email to authenticate with.
    # @option options [String, #to_s] :key The secret authentication key.
    # @option options [Hash, #to_h] :parameters ({}) The parameters to send with the HTTP request.
    # @option options [String, #to_s] :api_url (https://snapsearch.io/api/v1/robot) The URL to send the HTTP request to.
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
      request.body = @parameters.to_json
      
      HTTPI.post(request)
    rescue
      raise ConnectionException
    end
    
    # Retrieve the `content` or raise an error based on the `code` field in the JSON response.
    # 
    # @return [HTTPI::Response] The HTTP response object.
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
