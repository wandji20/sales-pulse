FactoryBot.define do
  factory :user do
    full_name { Faker::Name.name }
    telephone { Faker::Number.unique.number(digits: 9).to_s }
    password { 'password' }
    password_confirmation { 'password' }
    email_address { Faker::Internet.unique.email }
    confirmed { false }

    trait :confirmed do
      confirmed { true }
    end

    trait :confimed_admin do
      confirmed { true }
      role { 'admin' }
    end
  end
end
