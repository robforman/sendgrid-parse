require 'json'
require 'delegate'
require 'iconv' unless RUBY_VERSION >= '1.9'


module Sendgrid
  module Parse
    class EncodableHash < SimpleDelegator
      attr_accessor :component

      def class
        __getobj__.class
      end

      def initialize(component)
        # Symbolize keys
        if component.respond_to? :symbolize_keys
          component = component.symbolize_keys
        else
          component.keys.each { |key| component[(key.to_sym rescue key) || key] = component.delete(key) }
        end

        raise 'Missing required key :charsets for encoding.' unless component.has_key?(:charsets)
        super
      end

      def encode(to_encoding, ignore=[])
        component = __getobj__.dup
        ignore.each { |e| component.delete(e) if component.has_key?(e)}

        # Parse and symbolize charsets dictionary
        charsets = JSON.parse(component[:charsets])
        charsets.keys.each { |key| charsets[(key.to_sym rescue key) || key] = charsets.delete(key) }

        # Set and/or change all fields according to charsets
        component.each do |key, value|
          if charsets.has_key?(key)
            from_encoding = charsets[key]
            component[key] = _encode(component[key], from_encoding, to_encoding)
            charsets[key] = to_encoding
          else
            # If we weren't told, set it to the target encoding type.
            component[key] = _encode(component[key], to_encoding, to_encoding)
          end
        end

        component[:charsets] = charsets.to_json
        component
      end

      def encode!(to_encoding, ignore=[])
        __setobj__ encode(to_encoding, ignore)
      end

    protected
      def _encode(value, from, to)
        if RUBY_VERSION >= '1.9'
          value = value.force_encoding(from)
          value = value.encode(to, :invalid => :replace, :undef => :replace, :replace => '')
        else
          value = Iconv.conv("#{to}//IGNORE", from, value)
        end

        value
      end
    end
  end
end