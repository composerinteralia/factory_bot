FactoryBot.define do
  factory :factory, class: "FactoryBot::Factory" do
    initialize_with do
      options = {}
      if parent.present?
        options[:parent] = parent
      end
      new(name, options)
    end

    to_create do |factory|
      FactoryBot.register_factory(factory)
    end

    transient do
      sequence(:name) { |n| "factory-#{n}" }
      parent { nil }
    end
  end

  factory :sequence, class: "FactoryBot::Sequence" do
    initialize_with { new(name) }

    to_create do |sequence|
      FactoryBot.register_sequence(sequence)
    end

    transient do
      name { :sequence_name }
    end
  end

  factory :trait, class: "FactoryBot::Trait" do
    initialize_with { new(name) }

    to_create do |trait|
      FactoryBot.register_trait(trait)
    end

    transient do
      name { :trait_name }
    end
  end
end
