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
      raise TypeError, 'email must be a String or respond to #to_s' unless value.is_a?(String) || respond_to?(:to_s)
      
      value = value.to_s
      raise ArgumentError, 'email must be an email address' unless value.include?(?@)
      
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
    # @param [Hash, #to_h] value The value to set the attribute to.
    # @return [Hash] The new value of the attribute.
    def parameters=(value)
      raise TypeError, 'parameters must be a Hash or respond to #to_h' unless value.is_a?(Hash) || value.respond_to?(:to_h)
      
      @parameters = value.to_h
    end
    
    # Validate and set the value of the `api_url` attribute.
    # 
    # @param [String, #to_s] value The value to set the attribute to.
    # @return [String] The new value of the attribute.
    def api_url=(value)
      raise TypeError, 'api_url must be a String or respond_to #to_s' unless value.is_a?(String) || respond_to?(:to_s)
      
      @api_url = value.to_s
    end
    
    # Send an authenticated HTTP request to the `api_url` and return the `content` field from the JSON response body.
    # 
    # @param [String, #to_s] url The url to send in the parameters to the `api_url`.
    # @return [String] The `content` field from the JSON response body.
    def request(url)
      raise TypeError, 'url must be a String or respond_to #to_s' unless value.is_a?(String) || respond_to?(:to_s)
      @parameters['url'] = url.to_s # The URL must contain the entire URL with the _escaped_fragment_ parsed out
      
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
      raise TypeError, 'options must be a Hash or respond to #to_h' unless value.is_a?(Hash) || value.respond_to?(:to_h)
      
      options = {
        parameters: {},
        api_url: 'https://snapsearch.io/api/v1/robot'
      }.merge(options.to_h)
      
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
      else; false # System error on SnapSearch; Nothing we can do # TODO: Raise exception?
      end
    end
    
  end
  
end
