describe FactoryBot::Attribute::Association do
  let(:name)    { :author }
  let(:factory) { :user }
  let(:options) { FactoryOptions.new(factory_name: factory) }

  subject { FactoryBot::Attribute::Association.new(name, options) }

  it         { is_expected.to be_association }
  its(:name) { is_expected.to eq name }

  context "with a string name" do
    let(:name) { "name" }
    its(:name) { is_expected.to eq :name }
  end

  describe "#to_proc" do
    it "calls the __association__ method with the correct arguments" do
      evaluator = spy(:evaluator)

      evaluator.instance_exec(&subject.to_proc)

      expect(evaluator).to have_received(:association).with(options)
    end

    it "it returns the association" do
      association = double(:association)
      evaluator = double(:evaluator, association: association)

      result = evaluator.instance_exec(&subject.to_proc)

      expect(result).to eq association
    end
  end
end
