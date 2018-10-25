class FactoryOptions
  attr_reader :factory_name, :traits

  def initialize(factory_name:, traits_and_overrides: [])
    @overrides = traits_and_overrides.extract_options!
    @traits = [@overrides.delete(:factory), traits_and_overrides].flatten
    @factory_name = @traits.shift || factory_name
  end

  def has_traits?
    @traits.any?
  end

  def strategy
    @overrides[:strategy]
  end

  def overrides
    @overrides.except(:strategy)
  end

  def traits_and_overrides
    @traits + [@overrides]
  end

  def ==(other)
    factory_name == other.factory_name &&
      strategy == other.strategy &&
      traits_and_overrides == other.traits_and_overrides
  end
end
