require 'rails_helper'

RSpec.describe Product, type: :model do
  subject { create(:product) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_least(Constants::MIN_NAME_LENGTH) }
  it { should validate_length_of(:name).is_at_most(Constants::MAX_NAME_LENGTH) }

  it { should belong_to(:user) }
  it { should belong_to(:archived_by).class_name('User').optional }
  it { should have_many(:variants) }
end
