FactoryBot.define do
  factory :service_item do
    name { Faker::Lorem.unique.words(number: 2).join(' ') }
    description { Faker::Lorem.words(number: 20).join(' ') }

    association :user
  end
end
