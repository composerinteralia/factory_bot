module FactoryBot
  class Declaration
    # @api private
    class Association < Declaration
      def initialize(name, options)
        super(name, false)
        @options = options
      end

      def ==(other)
        name == other.name &&
          options == other.options
      end

      protected

      attr_reader :options

      private

      def build
        [Attribute::Association.new(name, options)]
      end
    end
  end
end
