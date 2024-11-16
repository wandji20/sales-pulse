FactoryBot.define do
  factory :record do
    category { 1 }
    price { 1500 }
    status { 1 }
    association :variant
    association :service_item
    association :user
  end
end
