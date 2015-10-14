require 'anima'

require 'rom/support/class_builder'

module ROM
  # Simple data-struct
  #
  # By default mappers use this as the model
  #
  # @api public
  class Struct
    # Coerce to hash
    #
    # @return [Hash]
    #
    # @api private
    def to_hash
      to_h
    end

    # Access attribute value
    #
    # @param [Symbol] name The name of the attribute
    #
    # @return [Object]
    #
    # @api public
    def [](name)
      instance_variable_get("@#{name}")
    end

    # Delegate unknown methods to the Coerced hash
    #
    # @api public
    def method_missing(method, *args, &block)
      to_h.send(method, *args, &block)
    end
  end
end
