require 'rails_helper'

RSpec.describe Variant, type: :model do
  subject { create(:variant) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:product_id) }
  it { should validate_length_of(:name).is_at_least(Constants::MIN_NAME_LENGTH) }
  it { should validate_length_of(:name).is_at_most(Constants::MAX_NAME_LENGTH) }
  it { should validate_presence_of(:buying_price) }
  it { should validate_numericality_of(:buying_price).is_in(Constants::MIN_PRICE..Constants::MAX_PRICE) }
  it { should validate_presence_of(:supply_price) }
  it { should validate_numericality_of(:supply_price).is_in(Constants::MIN_PRICE..Constants::MAX_PRICE) }

  it { should belong_to(:product) }
end
