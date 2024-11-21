FactoryBot.define do
  factory :product do
    name { Faker::Lorem.unique.words(number: 2) }
    association :user

    trait :archived do
      archived_by { association :user }
      archived_on { "2024-11-06 23:32:15" }
    end
  end
end
