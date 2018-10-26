class FactoryOptions
  attr_reader :factory_name, :traits, :strategy, :overrides

  def initialize(factory_name:, traits_and_overrides: [])
    @overrides = traits_and_overrides.extract_options!
    @traits = [@overrides.delete(:factory), traits_and_overrides].flatten
    @factory_name = @traits.shift || factory_name
    @strategy = @overrides.delete(:strategy)
  end

  def has_traits?
    @traits.any?
  end

  def ==(other)
    factory_name == other.factory_name &&
      strategy == other.strategy &&
      traits == other.traits &&
      overrides == other.overrides
  end
end
