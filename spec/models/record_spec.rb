require 'rails_helper'

RSpec.describe Record, type: :model do
  subject { create(:record) }

  it { should validate_presence_of(:price) }
  it { should validate_numericality_of(:price).is_greater_than(0) }
  it { should validate_presence_of(:category) }
  it { should validate_presence_of(:status) }

  it { should belong_to(:user) }
  it { should belong_to(:service_item).optional }
  it { should belong_to(:variant).optional }
end
