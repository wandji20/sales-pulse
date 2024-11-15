FactoryBot.define do
  factory :service_item do
    name { Faker::Lorem.word }
    description { Faker::Lorem.words(number: 20) }

    association :user
  end
end
