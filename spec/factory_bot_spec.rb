describe FactoryBot, :with_test_factories do
  it "finds a registered factory" do
    factory = FactoryBot.create(:factory)
    expect(FactoryBot.factory_by_name(factory.name)).to eq factory
  end

  it "finds a registered sequence" do
    sequence = FactoryBot.create(:sequence)
    expect(FactoryBot.sequence_by_name(sequence.name)).to eq sequence
  end

  it "finds a registered trait" do
    trait = FactoryBot.create(:trait)
    expect(FactoryBot.trait_by_name(trait.name)).to eq trait
  end
end
