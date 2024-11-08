require 'rails_helper'

RSpec.describe Variant, type: :model do
  subject { create(:variant, product: create(:product)) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:product_id) }
  it { should validate_length_of(:name).is_at_least(Constants::MIN_NAME_LENGTH) }
  it { should validate_length_of(:name).is_at_most(Constants::MAX_NAME_LENGTH) }

  it { should belong_to(:product) }
end
