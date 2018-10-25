module FactoryBot
  class Attribute
    # @api private
    class Association < Attribute
      attr_reader :factory

      def initialize(name, options)
        super(name, false)
        @options = options
        @factory = @options.factory_name
      end

      def to_proc
        options = @options

        -> { association(options.factory_name, *options.traits_and_overrides) }
      end

      def association?
        true
      end
    end
  end
end
