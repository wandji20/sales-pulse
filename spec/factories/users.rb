FactoryBot.define do
  factory :user do
    full_name { Faker::Name.name }
    telephone { Faker::Number.unique.number(digits: 9).to_s }
    password { 'password' }
    password_confirmation { 'password' }
    email_address { Faker::Internet.unique.email }
  end
end
