FactoryBot.define do
  factory :report_notification, class: 'Notifications::Report' do
    association :user
    message_type { 2 }
    delivery_type { 0 }

    type { "Notifications::Report" }
    subjectable { }
  end
end
