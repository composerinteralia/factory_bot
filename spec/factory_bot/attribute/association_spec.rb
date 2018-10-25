describe FactoryBot::Attribute::Association do
  let(:name)        { :author }
  let(:factory)     { :user }
  let(:overrides)   { { first_name: "John" } }
  let(:association) { double("association") }
  let(:options) do
    FactoryOptions.new(factory_name: factory, traits_and_overrides: [overrides])
  end

  subject { FactoryBot::Attribute::Association.new(name, options) }

  module MissingMethods
    def association(*args); end
  end

  before do
    # Define an '#association' instance method allowing it to be mocked.
    # Ususually this is determined via '#method_missing'
    subject.extend(MissingMethods)

    allow(subject).
      to receive(:association).with(any_args).and_return association
  end

  it         { should be_association }
  its(:name) { should eq name }

  it "builds the association when calling the proc" do
    expect(subject.to_proc.call).to eq association
  end

  it "builds the association when calling the proc" do
    subject.to_proc.call
    expect(subject).to have_received(:association).with(factory, overrides)
  end

  context "with a string name" do
    let(:name) { "name" }
    its(:name) { should eq :name }
  end
end
