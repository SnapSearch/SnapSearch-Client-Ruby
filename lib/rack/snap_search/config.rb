module Rack
  class SnapSearch
    
    # TODO: YARD
    class Config
      
      # TODO: YARD
      def initialize(middleware, options={})
        @middleware = middleware
        
        [:email, :key, :on_exception].each do |attribute|
          send( "#{attribute}=", options[attribute] ) if options.has_key?(attribute)
        end
      end
      
      attr_reader :email, :key
      
      # TODO: YARD
      def email=(value)
        # TODO: Complain if not string/valid email (super simple regexp)
        @email = value
      end
      
      # TODO: YARD
      def key=(value)
        # TODO: Complain if not string
        @key = value
      end
      
      # TODO: YARD
      def on_exception=(block)
        # TODO: Complain if not Proc
        @on_exception = block
      end
      
      # TODO: YARD
      def on_exception(&block)
        @on_exception = block if block_given?
        
        @on_exception
      end
      
    end
    
  end
end
