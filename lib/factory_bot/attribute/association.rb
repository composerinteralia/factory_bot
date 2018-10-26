module FactoryBot
  class Attribute
    # @api private
    class Association < Attribute

      def initialize(name, options)
        super(name, false)
        @options = options
      end

      def to_proc
        options = @options
        -> { association(options) }
      end

      def association?
        true
      end

      def factory
        @options.factory_name
      end
    end
  end
end
