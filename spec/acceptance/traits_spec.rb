describe "an instance generated by a factory with multiple traits" do
  before do
    define_model("User",
      name: :string,
      admin: :boolean,
      gender: :string,
      email: :string,
      date_of_birth: :date,
      great: :string)

    FactoryBot.define do
      factory :user do
        name { "John" }

        trait :great do
          great { "GREAT!!!" }
        end

        trait :great do
          great { "EVEN GREATER!!!" }
        end

        trait :admin do
          admin { true }
        end

        trait :admin_trait do
          admin { true }
        end

        trait :male do
          name { "Joe" }
          gender { "Male" }
        end

        trait :female do
          name { "Jane" }
          gender { "Female" }
        end

        factory :great_user do
          great
        end

        factory :even_greater_user do
          great

          trait :great do
            great { "EVEN GREATER!!!" }
          end
        end

        factory :admin, traits: [:admin]

        factory :male_user do
          male

          factory :child_male_user do
            date_of_birth { Date.parse("1/1/2000") }
          end
        end

        factory :female, traits: [:female] do
          trait :admin do
            admin { true }
            name { "Judy" }
          end

          factory :female_great_user do
            great
          end

          factory :female_admin_judy, traits: [:admin]
        end

        factory :female_admin, traits: [:female, :admin]
        factory :female_after_male_admin, traits: [:male, :female, :admin]
        factory :male_after_female_admin, traits: [:female, :male, :admin]
      end

      trait :email do
        email { "#{name}@example.com" }
      end

      factory :user_with_email, class: User, traits: [:email] do
        name { "Bill" }
      end
    end
  end

  context "the parent class" do
    subject { FactoryBot.create(:user) }
    its(:name) { should eq "John" }
    its(:gender) { should be_nil }
    it { should_not be_admin }
  end

  context "the child class with one trait" do
    subject { FactoryBot.create(:admin) }
    its(:name) { should eq "John" }
    its(:gender) { should be_nil }
    it { should be_admin }
  end

  context "the other child class with one trait" do
    subject { FactoryBot.create(:female) }
    its(:name) { should eq "Jane" }
    its(:gender) { should eq "Female" }
    it { should_not be_admin }
  end

  context "the child with multiple traits" do
    subject { FactoryBot.create(:female_admin) }
    its(:name) { should eq "Jane" }
    its(:gender) { should eq "Female" }
    it { should be_admin }
  end

  context "the child with multiple traits and overridden attributes" do
    subject { FactoryBot.create(:female_admin, name: "Jill", gender: nil) }
    its(:name) { should eq "Jill" }
    its(:gender) { should be_nil }
    it { should be_admin }
  end

  context "the child with multiple traits who override the same attribute" do
    context "when the male assigns name after female" do
      subject { FactoryBot.create(:male_after_female_admin) }
      its(:name) { should eq "Joe" }
      its(:gender) { should eq "Male" }
      it { should be_admin }
    end

    context "when the female assigns name after male" do
      subject { FactoryBot.create(:female_after_male_admin) }
      its(:name) { should eq "Jane" }
      its(:gender) { should eq "Female" }
      it { should be_admin }
    end
  end

  context "child class with scoped trait and inherited trait" do
    subject { FactoryBot.create(:female_admin_judy) }
    its(:name) { should eq "Judy" }
    its(:gender) { should eq "Female" }
    it { should be_admin }
  end

  context "factory using global trait" do
    subject { FactoryBot.create(:user_with_email) }
    its(:name) { should eq "Bill" }
    its(:email) { should eq "Bill@example.com" }
  end

  context "factory created with alternate syntax for specifying trait" do
    subject { FactoryBot.create(:male_user) }
    its(:gender) { should eq "Male" }

    context "where trait name and attribute are the same" do
      subject { FactoryBot.create(:great_user) }
      its(:great) { should eq "GREAT!!!" }
    end

    context "where trait name and attribute are the same and attribute is overridden" do
      subject { FactoryBot.create(:great_user, great: "SORT OF!!!") }
      its(:great) { should eq "SORT OF!!!" }
    end
  end

  context "factory with trait defined multiple times" do
    subject { FactoryBot.create(:great_user) }
    its(:great) { should eq "GREAT!!!" }

    context "child factory redefining trait" do
      subject { FactoryBot.create(:even_greater_user) }
      its(:great) { should eq "EVEN GREATER!!!" }
    end
  end

  context "child factory created where trait attributes are inherited" do
    subject { FactoryBot.create(:child_male_user) }
    its(:gender) { should eq "Male" }
    its(:date_of_birth) { should eq Date.parse("1/1/2000") }
  end

  context "child factory using grandparents' trait" do
    subject { FactoryBot.create(:female_great_user) }
    its(:great) { should eq "GREAT!!!" }
  end
end

describe "trait indifferent access" do
  context "when trait is defined as a string" do
    it "can be invoked with a string" do
      build_user_factory_with_admin_trait("admin")

      user = FactoryBot.build(:user, "admin")

      expect(user).to be_admin
    end

    it "can be invoked with a symbol" do
      build_user_factory_with_admin_trait("admin")

      user = FactoryBot.build(:user, :admin)

      expect(user).to be_admin
    end
  end

  context "when trait is defined as a symbol" do
    it "can be invoked with a string" do
      build_user_factory_with_admin_trait(:admin)

      user = FactoryBot.build(:user, "admin")

      expect(user).to be_admin
    end

    it "can be invoked with a symbol" do
      build_user_factory_with_admin_trait(:admin)

      user = FactoryBot.build(:user, :admin)

      expect(user).to be_admin
    end
  end

  context "when trait is defined as integer" do
    it "can be invoked with a string" do
      build_user_factory_with_admin_trait(42)

      user = FactoryBot.build(:user, "42")

      expect(user).to be_admin
    end

    it "can be invoked with as integer" do
      build_user_factory_with_admin_trait(42)

      user = FactoryBot.build(:user, 42)

      expect(user).to be_admin
    end
  end

  context "when trait is defined as struct" do
    it "can be invoked with a string" do
      instance = Struct.new(:a, :b).new(1, "x")
      build_user_factory_with_admin_trait(instance)

      user = FactoryBot.build(:user, '#<struct a=1, b="x">')

      expect(user).to be_admin
    end

    it "can be invoked with a struct" do
      instance = Struct.new(:a, :b).new(1, "x")
      build_user_factory_with_admin_trait(instance)

      user = FactoryBot.build(:user, instance)

      expect(user).to be_admin
    end
  end

  def build_user_factory_with_admin_trait(trait_name)
    define_model("User", admin: :boolean)

    FactoryBot.define do
      factory :user do
        admin { false }

        trait trait_name do
          admin { true }
        end
      end
    end
  end
end

describe "looking up traits that don't exist" do
  context "when passing an invalid override trait" do
    it "raises a KeyError" do
      define_class("User")

      FactoryBot.define do
        factory :user
      end

      expect { FactoryBot.build(:user, double("not a trait")) }
        .to raise_error(KeyError)
    end

    it "adds 'Did you mean?' suggestions at the end of the error message" do
      define_class("User")

      FactoryBot.define do
        trait :not_quit

        factory :user do
          trait :not_quote
          trait :unrelated
        end
      end

      expect { FactoryBot.build(:user, :not_quite) }.to raise_error(
        KeyError,
        <<~MSG.strip
          Trait not registered: "not_quite"
          Did you mean?  "not_quit"
                         "not_quote"
        MSG
      )
    end
  end

  context "when the factory includes an invalid default trait" do
    it "raises a KeyError including the factory name" do
      define_class("User")

      FactoryBot.define do
        factory :user do
          inaccessible_trait
        end

        factory :some_other_factory do
          trait :inaccessible_trait
        end
      end

      expect { FactoryBot.build(:user) }.to raise_error(
        KeyError,
        'Trait not registered: "inaccessible_trait" referenced within "user" definition'
      )
    end

    it "adds 'Did you mean?' suggestions at the end of the error message" do
      define_class("User")

      FactoryBot.define do
        trait :not_quit

        factory :user do
          trait :not_quote
          trait :unrelated

          not_quite
        end
      end

      expect { FactoryBot.build(:user) }.to raise_error(
        KeyError,
        <<~MSG.strip
          Trait not registered: "not_quite" referenced within "user" definition
          Did you mean?  "not_quit"
                         "not_quote"
        MSG
      )
    end
  end

  context "when a trait includes an invalid default trait" do
    it "raises a KeyError including the factory name" do
      define_class("User")

      FactoryBot.define do
        factory :user do
          trait :admin do
            inaccessible_trait
          end
        end

        factory :some_other_factory do
          trait :inaccessible_trait
        end
      end

      expect { FactoryBot.build(:user, :admin) }.to raise_error(
        KeyError,
        'Trait not registered: "inaccessible_trait" referenced within "admin" definition'
      )
    end
  end
end

describe "traits with callbacks" do
  before do
    define_model("User", name: :string)

    FactoryBot.define do
      factory :user do
        name { "John" }

        trait :great do
          after(:create) { |user| user.name.upcase! }
        end

        trait :awesome do
          after(:create) { |user| user.name = "awesome" }
        end

        factory :caps_user, traits: [:great]
        factory :awesome_user, traits: [:great, :awesome]

        factory :caps_user_implicit_trait do
          great
        end
      end
    end
  end

  context "when the factory has a trait passed via arguments" do
    subject { FactoryBot.create(:caps_user) }
    its(:name) { should eq "JOHN" }
  end

  context "when the factory has an implicit trait" do
    subject { FactoryBot.create(:caps_user_implicit_trait) }
    its(:name) { should eq "JOHN" }
  end

  it "executes callbacks in the order assigned" do
    expect(FactoryBot.create(:awesome_user).name).to eq "awesome"
  end
end

describe "traits added via strategy" do
  before do
    define_model("User", name: :string, admin: :boolean)

    FactoryBot.define do
      factory :user do
        name { "John" }

        trait :admin do
          admin { true }
        end

        trait :great do
          after(:create) { |user| user.name.upcase! }
        end
      end
    end
  end

  context "adding traits in create" do
    subject { FactoryBot.create(:user, :admin, :great, name: "Joe") }

    its(:admin) { should be true }
    its(:name) { should eq "JOE" }

    it "doesn't modify the user factory" do
      subject
      expect(FactoryBot.create(:user)).not_to be_admin
      expect(FactoryBot.create(:user).name).to eq "John"
    end
  end

  context "adding traits in build" do
    subject { FactoryBot.build(:user, :admin, :great, name: "Joe") }

    its(:admin) { should be true }
    its(:name) { should eq "Joe" }
  end

  context "adding traits in attributes_for" do
    subject { FactoryBot.attributes_for(:user, :admin, :great) }

    its([:admin]) { should be true }
    its([:name]) { should eq "John" }
  end

  context "adding traits in build_stubbed" do
    subject { FactoryBot.build_stubbed(:user, :admin, :great, name: "Jack") }

    its(:admin) { should be true }
    its(:name) { should eq "Jack" }
  end

  context "adding traits in create_list" do
    subject { FactoryBot.create_list(:user, 2, :admin, :great, name: "Joe") }

    its(:length) { should eq 2 }

    it "creates all the records" do
      subject.each do |record|
        expect(record.admin).to be true
        expect(record.name).to eq "JOE"
      end
    end
  end

  context "adding traits in build_list" do
    subject { FactoryBot.build_list(:user, 2, :admin, :great, name: "Joe") }

    its(:length) { should eq 2 }

    it "builds all the records" do
      subject.each do |record|
        expect(record.admin).to be true
        expect(record.name).to eq "Joe"
      end
    end
  end
end

describe "traits and dynamic attributes that are applied simultaneously" do
  before do
    define_model("User", name: :string, email: :string, combined: :string)

    FactoryBot.define do
      trait :email do
        email { "#{name}@example.com" }
      end

      factory :user do
        name { "John" }
        email
        combined { "#{name} <#{email}>" }
      end
    end
  end

  subject { FactoryBot.build(:user) }
  its(:name) { should eq "John" }
  its(:email) { should eq "John@example.com" }
  its(:combined) { should eq "John <John@example.com>" }
end

describe "applying inline traits" do
  before do
    define_model("User") do
      has_many :posts
    end

    define_model("Post", user_id: :integer) do
      belongs_to :user
    end

    FactoryBot.define do
      factory :user do
        trait :with_post do
          posts { [Post.new] }
        end
      end
    end
  end

  it "applies traits only to the instance generated for that call" do
    expect(FactoryBot.create(:user, :with_post).posts).not_to be_empty
    expect(FactoryBot.create(:user).posts).to be_empty
    expect(FactoryBot.create(:user, :with_post).posts).not_to be_empty
  end
end

describe "inline traits overriding existing attributes" do
  before do
    define_model("User", status: :string)

    FactoryBot.define do
      factory :user do
        status { "pending" }

        trait(:accepted) { status { "accepted" } }
        trait(:declined) { status { "declined" } }

        factory :declined_user, traits: [:declined]
        factory :extended_declined_user, traits: [:declined] do
          status { "extended_declined" }
        end
      end
    end
  end

  it "returns the default status" do
    expect(FactoryBot.build(:user).status).to eq "pending"
  end

  it "prefers inline trait attributes over default attributes" do
    expect(FactoryBot.build(:user, :accepted).status).to eq "accepted"
  end

  it "prefers traits on a factory over default attributes" do
    expect(FactoryBot.build(:declined_user).status).to eq "declined"
  end

  it "prefers inline trait attributes over traits on a factory" do
    expect(FactoryBot.build(:declined_user, :accepted).status).to eq "accepted"
  end

  it "prefers attributes on factories over attributes from non-inline traits" do
    expect(FactoryBot.build(:extended_declined_user).status).to eq "extended_declined"
  end

  it "prefers inline traits over attributes on factories" do
    expect(FactoryBot.build(:extended_declined_user, :accepted).status).to eq "accepted"
  end

  it "prefers overridden attributes over attributes from traits, inline traits, or attributes on factories" do
    user = FactoryBot.build(:extended_declined_user, :accepted, status: "completely overridden")

    expect(user.status).to eq "completely overridden"
  end
end

describe "making sure the factory is properly compiled the first time we want to instantiate it" do
  before do
    define_model("User", role: :string, gender: :string, age: :integer)

    FactoryBot.define do
      factory :user do
        trait(:female) { gender { "female" } }
        trait(:admin) { role { "admin" } }

        factory :female_user do
          female
        end
      end
    end
  end

  it "can honor traits on the very first call" do
    user = FactoryBot.build(:female_user, :admin, age: 30)
    expect(user.gender).to eq "female"
    expect(user.age).to eq 30
    expect(user.role).to eq "admin"
  end
end

describe "traits with to_create" do
  before do
    define_model("User", name: :string)

    FactoryBot.define do
      factory :user do
        trait :with_to_create do
          to_create { |instance| instance.name = "to_create" }
        end

        factory :sub_user do
          to_create { |instance| instance.name = "sub" }

          factory :child_user
        end

        factory :sub_user_with_trait do
          with_to_create

          factory :child_user_with_trait
        end

        factory :sub_user_with_trait_and_override do
          with_to_create
          to_create { |instance| instance.name = "sub with trait and override" }

          factory :child_user_with_trait_and_override
        end
      end
    end
  end

  it "can apply to_create from traits" do
    expect(FactoryBot.create(:user, :with_to_create).name).to eq "to_create"
  end

  it "can apply to_create from the definition" do
    expect(FactoryBot.create(:sub_user).name).to eq "sub"
    expect(FactoryBot.create(:child_user).name).to eq "sub"
  end

  it "gives additional traits higher priority than to_create from the definition" do
    expect(FactoryBot.create(:sub_user, :with_to_create).name).to eq "to_create"
    expect(FactoryBot.create(:child_user, :with_to_create).name).to eq "to_create"
  end

  it "gives base traits normal priority" do
    expect(FactoryBot.create(:sub_user_with_trait).name).to eq "to_create"
    expect(FactoryBot.create(:child_user_with_trait).name).to eq "to_create"
  end

  it "gives base traits lower priority than overrides" do
    expect(FactoryBot.create(:sub_user_with_trait_and_override).name).to eq "sub with trait and override"
    expect(FactoryBot.create(:child_user_with_trait_and_override).name).to eq "sub with trait and override"
  end

  it "gives additional traits higher priority than base traits and factory definition" do
    FactoryBot.define do
      trait :overridden do
        to_create { |instance| instance.name = "completely overridden" }
      end
    end

    sub_user = FactoryBot.create(:sub_user_with_trait_and_override, :overridden)
    child_user = FactoryBot.create(:child_user_with_trait_and_override, :overridden)
    expect(sub_user.name).to eq "completely overridden"
    expect(child_user.name).to eq "completely overridden"
  end
end

describe "traits with initialize_with" do
  before do
    define_class("User") do
      attr_reader :name

      def initialize(name)
        @name = name
      end
    end

    FactoryBot.define do
      factory :user do
        trait :with_initialize_with do
          initialize_with { new("initialize_with") }
        end

        factory :sub_user do
          initialize_with { new("sub") }

          factory :child_user
        end

        factory :sub_user_with_trait do
          with_initialize_with

          factory :child_user_with_trait
        end

        factory :sub_user_with_trait_and_override do
          with_initialize_with
          initialize_with { new("sub with trait and override") }

          factory :child_user_with_trait_and_override
        end
      end
    end
  end

  it "can apply initialize_with from traits" do
    expect(FactoryBot.build(:user, :with_initialize_with).name).to eq "initialize_with"
  end

  it "can apply initialize_with from the definition" do
    expect(FactoryBot.build(:sub_user).name).to eq "sub"
    expect(FactoryBot.build(:child_user).name).to eq "sub"
  end

  it "gives additional traits higher priority than initialize_with from the definition" do
    expect(FactoryBot.build(:sub_user, :with_initialize_with).name).to eq "initialize_with"
    expect(FactoryBot.build(:child_user, :with_initialize_with).name).to eq "initialize_with"
  end

  it "gives base traits normal priority" do
    expect(FactoryBot.build(:sub_user_with_trait).name).to eq "initialize_with"
    expect(FactoryBot.build(:child_user_with_trait).name).to eq "initialize_with"
  end

  it "gives base traits lower priority than overrides" do
    expect(FactoryBot.build(:sub_user_with_trait_and_override).name).to eq "sub with trait and override"
    expect(FactoryBot.build(:child_user_with_trait_and_override).name).to eq "sub with trait and override"
  end

  it "gives additional traits higher priority than base traits and factory definition" do
    FactoryBot.define do
      trait :overridden do
        initialize_with { new("completely overridden") }
      end
    end

    sub_user = FactoryBot.build(:sub_user_with_trait_and_override, :overridden)
    child_user = FactoryBot.build(:child_user_with_trait_and_override, :overridden)
    expect(sub_user.name).to eq "completely overridden"
    expect(child_user.name).to eq "completely overridden"
  end
end

describe "nested implicit traits" do
  before do
    define_class("User") do
      attr_accessor :gender, :role
      attr_reader :name

      def initialize(name)
        @name = name
      end
    end
  end

  shared_examples_for "assigning data from traits" do
    it "assigns the correct values" do
      user = FactoryBot.create(:user, :female_admin)
      expect(user.gender).to eq "FEMALE"
      expect(user.role).to eq "ADMIN"
      expect(user.name).to eq "Jane Doe"
    end
  end

  context "defined outside the factory" do
    before do
      FactoryBot.define do
        trait :female do
          gender { "female" }
          to_create { |instance| instance.gender = instance.gender.upcase }
        end

        trait :jane_doe do
          initialize_with { new("Jane Doe") }
        end

        trait :admin do
          role { "admin" }
          after(:build) { |instance| instance.role = instance.role.upcase }
        end

        trait :female_admin do
          female
          admin
          jane_doe
        end

        factory :user
      end
    end

    it_should_behave_like "assigning data from traits"
  end

  context "defined inside the factory" do
    before do
      FactoryBot.define do
        factory :user do
          trait :female do
            gender { "female" }
            to_create { |instance| instance.gender = instance.gender.upcase }
          end

          trait :jane_doe do
            initialize_with { new("Jane Doe") }
          end

          trait :admin do
            role { "admin" }
            after(:build) { |instance| instance.role = instance.role.upcase }
          end

          trait :female_admin do
            female
            admin
            jane_doe
          end
        end
      end
    end

    it_should_behave_like "assigning data from traits"
  end
end

describe "implicit traits containing callbacks" do
  before do
    define_model("User", value: :integer)

    FactoryBot.define do
      factory :user do
        value { 0 }

        trait :trait_with_callback do
          after(:build) { |user| user.value += 1 }
        end

        factory :user_with_trait_with_callback do
          trait_with_callback
        end
      end
    end
  end

  it "only runs the callback once" do
    expect(FactoryBot.build(:user_with_trait_with_callback).value).to eq 1
  end
end

describe "traits used in associations" do
  before do
    define_model("User", admin: :boolean, name: :string)

    define_model("Comment", user_id: :integer) do
      belongs_to :user
    end

    define_model("Order", creator_id: :integer) do
      belongs_to :creator, class_name: "User"
    end

    define_model("Post", author_id: :integer) do
      belongs_to :author, class_name: "User"
    end

    FactoryBot.define do
      factory :user do
        admin { false }

        trait :admin do
          admin { true }
        end
      end

      factory :post do
        association :author, factory: [:user, :admin], name: "John Doe"
      end

      factory :comment do
        association :user, :admin, name: "Joe Slick"
      end

      factory :order do
        association :creator, :admin, factory: :user, name: "Joe Creator"
      end
    end
  end

  it "allows assigning traits for the factory of an association" do
    author = FactoryBot.create(:post).author
    expect(author).to be_admin
    expect(author.name).to eq "John Doe"
  end

  it "allows inline traits with the default association" do
    user = FactoryBot.create(:comment).user
    expect(user).to be_admin
    expect(user.name).to eq "Joe Slick"
  end

  it "allows inline traits with a specific factory for an association" do
    creator = FactoryBot.create(:order).creator
    expect(creator).to be_admin
    expect(creator.name).to eq "Joe Creator"
  end
end

describe "when a self-referential trait is defined" do
  it "raises a TraitDefinitionError" do
    define_model("User", name: :string)
    FactoryBot.define do
      factory :user do
        trait :admin do
          admin
        end
      end
    end

    expect { FactoryBot.build(:user, :admin) }.to raise_error(
      FactoryBot::TraitDefinitionError,
      "Self-referencing trait 'admin'"
    )
  end

  it "raises a TraitDefinitionError" do
    define_model("User", name: :string)
    FactoryBot.define do
      factory :user do
        trait :admin do
          admin
          name { "name" }
        end
      end
    end

    expect { FactoryBot.build(:user, :admin) }.to raise_error(
      FactoryBot::TraitDefinitionError,
      "Self-referencing trait 'admin'"
    )
  end
end
