FactoryBot.define do
  factory :variant do
    name { "#{Faker::Appliance.equipment} - #{Faker::Lorem.unique.characters(number: 2)}" }
    supply_price { 1300 }
    buying_price { 1000 }
    quantity { Faker::Number.within(range: 10..100) }
    association :product
    previous_quantity { nil }
  end
end
