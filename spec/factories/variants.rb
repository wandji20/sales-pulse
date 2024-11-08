FactoryBot.define do
  factory :variant do
    name { Faker::Appliance.unique.equipment }
    price { 1.5 }
    quantity { Faker::Number }
    association :product
  end
end
