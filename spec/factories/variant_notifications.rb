FactoryBot.define do
  factory :variant_notification, class: 'Notifications::Variant' do
    association :user
    message_type { 0 }
    delivery_type { 0 }

    type { "Notifications::Variant" }
    association :subjectable, factory: :variant
  end
end
