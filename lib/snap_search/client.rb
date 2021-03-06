require 'json'
require 'httpi'
require 'snap_search/connection_error'
require 'snap_search/validation_error'

module SnapSearch
    
    # The Client sends an authenticated HTTP request to the SnapChat API and returns the `content`
    # field from the JSON response body.
    class Client
        
        attr_reader :email, :key, :parameters, :api_url, :ca_cert_file
        
        # Create a new Client instance.
        # 
        # @param [Hash, #to_h] options The options to create the Client with.
        # @option options [String, #to_s] :email The email to authenticate with.
        # @option options [String, #to_s] :key The secret authentication key.
        # @option options [Hash, #to_h] :parameters ({}) The parameters to send with the HTTP request.
        # @option options [String, #to_s] :api_url (https://snapsearch.io/api/v1/robot) The URL to send the HTTP request to.
        # @option options [String, #to_s] :ca_cert_file (ROOT/resources/cacert.pem) The CA cert file to use with request.
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
            raise TypeError, 'parameters must be a Hash or respond to #to_h or #to_hash' unless value.is_a?(Hash) || value.respond_to?(:to_h) || value.respond_to?(:to_hash)
            value = value.to_h rescue value.to_hash
            
            @parameters = value.to_h
        end
        
        # Validate and set the value of the `api_url` attribute.
        # 
        # @param [String, #to_s] value The value to set the attribute to.
        # @return [String] The new value of the attribute.
        def api_url=(value)
            raise TypeError, 'api_url must be a String or respond_to #to_s' unless value.is_a?(String) || value.respond_to?(:to_s)
            
            @api_url = value.to_s
        end
        
        # Validate and set the value of the `ca_cert_file` attribute.
        # 
        # @param [String, #to_s] value The value to set the attribute to.
        # @return [String] The new value of the attribute.
        def ca_cert_file=(value)
            raise TypeError, 'ca_cert_file must be a String or respond_to #to_s' unless value.is_a?(String) || value.respond_to?(:to_s)
            
            @ca_cert_file = value.to_s
        end
        
        # Send an authenticated HTTP request to the `api_url` and return the `content` field from the JSON response body.
        # 
        # @param [String, #to_s] url The url to send in the parameters to the `api_url`.
        # @return [String] The `content` field from the JSON response body.
        def request(url)
            raise TypeError, 'url must be a String or respond_to #to_s' unless url.is_a?(String) || url.respond_to?(:to_s)
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
        # @option options [String, #to_s] :ca_cert_file (ROOT/resources/cacert.pem) The CA cert file to use with request.
        def initialize_attributes(options)
            raise TypeError, 'options must be a Hash or respond to #to_h' unless options.is_a?(Hash) || options.respond_to?(:to_h) || options.respond_to?(:to_hash)
            options = options.to_h rescue options.to_hash
            
            options = {
                parameters: {},
                api_url: 'https://snapsearch.io/api/v1/robot',
                ca_cert_file: SnapSearch.root.join('resources', 'cacert.pem')
            }.merge(options.to_h)
            
            self.email, self.key, self.parameters, self.api_url, self.ca_cert_file = options.values_at(:email, :key, :parameters, :api_url, :ca_cert_file)
        end
        
        # Send an authenticated HTTP POST request encoded in JSON to the API URL
        # using the HTTP client adapter of the developer's choice.
        # 
        # @return [HTTPI::Response] The HTTP response object.
        def send_request
            request = HTTPI::Request.new
            request.url = api_url
            request.auth.basic(email, key)
            request.auth.ssl.ca_cert_file = ca_cert_file
            request.auth.ssl.verify_mode = :peer
            request.open_timeout = 30
            request.headers['Content-Type'] = 'application/json'
            request.headers['Accept-Encoding'] = 'gzip, deflate, identity'
            request.body = @parameters.to_json
            
            HTTPI.post(request)
        rescue
            raise ConnectionError
        end
        
        # Retrieve the `content` or raise an error based on the `code` field in the JSON response.
        # 
        # @return [HTTPI::Response] The HTTP response object.
        def content_from_response(response)
            body = JSON.parse(response.body)
            
            case body['code']
            when 'success' then body['content']
            when 'validation_error' then raise( ValidationError, body['content'] )
            else; false # System error on SnapSearch; Nothing we can do # TODO: Raise exception?
            end
        end
        
    end
    
end
