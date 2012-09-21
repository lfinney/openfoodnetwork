require 'faker'
require 'spree/core/testing_support/factories'

FactoryGirl.define do
  factory :supplier, :class => Spree::Supplier do
    sequence(:name) { |n| "Supplier #{n}" }
    description 'supplier'
    email       'supplier@example.com'
    address { Spree::Address.first || FactoryGirl.create(:address) }
  end

  factory :distributor, :class => Spree::Distributor do
    sequence(:name)    { |n| "Distributor #{n}" }
    contact            'Mr Turing'
    phone              '1000100100'
    description        'The creator'
    email              'alan@somewhere.com'
    url                'http://example.com'
    pickup_times       "Whenever you're free"
    next_collection_at 'Thursday 10am'
    pickup_address     { Spree::Address.first || FactoryGirl.create(:address) }
  end

  factory :product_distribution, :class => Spree::ProductDistribution do
    product         { |pd| Spree::Product.first        || FactoryGirl.create(:product) }
    distributor     { |pd| Spree::Distributor.first    || FactoryGirl.create(:distributor) }
    shipping_method { |pd| Spree::ShippingMethod.where("name != 'Delivery'").first || FactoryGirl.create(:shipping_method) }
  end

  factory :itemwise_shipping_method, :parent => :shipping_method do
    name 'Delivery'
    calculator { FactoryGirl.build(:itemwise_calculator) }
  end

  factory :itemwise_calculator, :class => OpenFoodWeb::Calculator::Itemwise do
  end
end


FactoryGirl.modify do
  factory :simple_product do
    # Fix product factory name sequence with Kernel.rand so it is not interpreted as a Spree::Product method
    # Pull request: https://github.com/spree/spree/pull/1964
    # When this fix has been merged into a version of Spree that we're using, this line can be removed.
    sequence(:name) { |n| "Product ##{n} - #{Kernel.rand(9999)}" }

    supplier { Spree::Supplier.first || FactoryGirl.create(:supplier) }
    on_hand 3

    # before(:create) do |product, evaluator|
    #   product.product_distributions = [FactoryGirl.create(:product_distribution, :product => product)]
    # end

    # Do not create products distributed via the 'Delivery' shipping method
    after(:create) do |product, evaluator|
      pd = product.product_distributions.first
      if pd.andand.shipping_method.andand.name == 'Delivery'
        pd.shipping_method = Spree::ShippingMethod.where("name != 'Delivery'").first || FactoryGirl.create(:shipping_method)
        pd.save!
      end
    end
  end

  factory :line_item do
    shipping_method { |li| li.product.shipping_method_for_distributor(li.order.distributor) }
  end

  factory :shipping_method do
    display_on ''
  end

  factory :address do
    state { Spree::State.find_by_name 'Victoria' }
    country { Spree::Country.find_by_name 'Australia' || Spree::Country.first }
  end
end
