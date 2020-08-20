module FactoryBot
  # TODO: Define the adapter only if need, perhaps?
  class KeyErrorAdapter < KeyError
    def initialize(message, receiver:, key:)
      @message = message
      @receiver = receiver
      @key = key
    end

    def to_s
      @message + did_you_mean
    end

    private

    attr_reader :receiver, :key

    def did_you_mean
      checker = DidYouMean::SpellChecker.new(dictionary: receiver)
      suggestions = checker.correct(key).map(&:inspect)
      DidYouMean.formatter.message_for(suggestions)
    end
  end

  # Raised when a factory is defined that attempts to instantiate itself.
  class AssociationDefinitionError < RuntimeError; end

  # Raised when a trait is defined that references itself.
  class TraitDefinitionError < RuntimeError; end

  # Raised when a callback is defined that has an invalid name
  class InvalidCallbackNameError < RuntimeError; end

  # Raised when a factory is defined with the same name as a previously-defined factory.
  class DuplicateDefinitionError < RuntimeError; end

  # Raised when attempting to register a sequence from a dynamic attribute block
  class SequenceAbuseError < RuntimeError; end

  # Raised when defining an attribute twice in the same factory
  class AttributeDefinitionError < RuntimeError; end

  # Raised when attempting to pass a block to an association definition
  class AssociationDefinitionError < RuntimeError; end

  # Raised when a method is defined in a factory or trait with arguments
  class MethodDefinitionError < RuntimeError; end

  # Raised when any factory is considered invalid
  class InvalidFactoryError < RuntimeError; end
end
