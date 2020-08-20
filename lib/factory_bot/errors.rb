module FactoryBot
  # Raised when a trait is referenced that was not defined
  class MissingTraitError < KeyError
    def initialize(error, trait_name, definition)
      @trait_name = trait_name
      @definition = definition

      set_backtrace(error.backtrace)
    end

    MESSAGE = "Trait not registered: \"%s\" referenced within \"%s\" definition"

    def to_s
      MESSAGE % [trait_name, definition.name] + did_you_mean
    end

    private

    attr_reader :error, :definition, :trait_name

    def available_traits
      definition.defined_traits.map(&:name) + Internal.traits.map(&:name)
    end

    def did_you_mean
      checker = DidYouMean::SpellChecker.new(dictionary: available_traits)
      suggestions = checker.correct(trait_name).map(&:inspect)
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
