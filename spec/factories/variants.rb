FactoryBot.define do
  factory :variant do
    name { Faker::Appliance.unique.equipment }
    price { 1000 }
    quantity { Faker::Number.within(range: 10..100) }
    association :product
    previous_quantity { nil }
  end
end
