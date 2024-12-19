FactoryBot.define do
  factory :product do
    name { Faker::Lorem.unique.words(number: 2).join(' ') }
    association :user

    trait :archived do
      archived_by { association :user }
      archived_on { "2024-11-06 23:32:15" }
    end

    factory :product_with_variants do
      transient do
        variants_count { 2 }
      end

      after(:create) do |product, evaluator|
        create_list(:variant, evaluator.variants_count, product:)

        product.reload
      end
    end
  end
end
