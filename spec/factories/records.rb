FactoryBot.define do
  factory :record do
    category { 0 }
    unit_price { 1500 }
    quantity { 3 }
    status { 1 }
    association :variant
    association :service_item
    association :user
    customer { association :user }
  end
end
