module Rack
    class SnapSearch
        
        # The configuration class for the Rack middleware. Simply holds the email, key, and on_exception attributes
        class Config
            
            # Create a new instance.
            # 
            # @param [Hash] options The options to initialize this instance with.
            # @option options [String] :email The email to authenticate with.
            # @option options [String] :key The key to authenticate with.
            # @option options [Proc] :on_exception The block to run when an exception within SnapSearch occurs.
            def initialize(options={})
                [:email, :key, :x_forwarded_proto, :on_exception].each do |attribute|
                    send( "#{attribute}=", options[attribute] ) if options.has_key?(attribute)
                end
            end
            
            attr_reader :email, :key, :x_forwarded_proto
            
            # Setter for the `email` attribute.
            # 
            # @param [String, #to_s] value The value to set the attribute as.
            # @return [String] The new value.
            def email=(value)
                raise TypeError, 'email must be a String or respond to #to_s' unless value.is_a?(String) || respond_to?(:to_s)
                
                @email = value.to_s
            end
            
            # Setter for the `key` attribute.
            # 
            # @param [String, #to_s] value The value to set the attribute as.
            # @return [String] The new value.
            def key=(value)
                raise TypeError, 'key must be a String or respond to #to_s' unless value.is_a?(String) || respond_to?(:to_s)
                
                @key = value.to_s
            end
            
            # Setter for the `x_forwarded_proto` attribute.
            # 
            # @param [true, false] value The value to set the attribute as.
            # @return [true, false] The new value.
            def x_forwarded_proto=(value)
                @x_forwarded_proto = !!value
            end
            
            # Setter for the `on_exception` attribute.
            # 
            # @param [Proc, #call] value The value to set the attribute as.
            # @return [Proc, #call] The new value.
            def on_exception=(value)
                raise TypeError, 'on_exception must be a Proc or respond to #call' unless value.is_a?(Proc) || value.respond_to?(:call)
                
                @on_exception = value
            end
            
            # Getter/Setter for the `on_exception` attribute.
            # 
            # @yield If given, the Proc to set the attribute as.
            # @return [Proc] The new value.
            def on_exception(&value)
                @on_exception = value if block_given?
                
                @on_exception
            end
            
        end
        
    end
end
