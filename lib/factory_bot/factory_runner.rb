module FactoryBot
  class FactoryRunner
    def initialize(strategy, options)
      @options = options
      @strategy = strategy
    end

    def run(runner_strategy = @strategy, &block)
      factory = FactoryBot.factory_by_name(@options.factory_name)

      factory.compile

      if @options.has_traits?
        factory = factory.with_traits(@options.traits)
      end

      instrumentation_payload = {
        name: @options.factory_name,
        strategy: runner_strategy,
        traits: @options.traits,
        overrides: @options.overrides,
        factory: factory,
      }

      ActiveSupport::Notifications.instrument("factory_bot.run_factory", instrumentation_payload) do
        factory.run(runner_strategy, @options.overrides, &block)
      end
    end
  end
end
