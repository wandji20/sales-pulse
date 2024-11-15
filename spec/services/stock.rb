require 'rails_helper'

RSpec.describe Stock, type: :model do
  let(:variant) { create(:variant) }
  # let(:operation) { Constants::STOCK_OPERATIONS.sample }
  # let(:quantity) { 10 }
  describe 'managing variant stock' do
    context 'with invalid input' do
      let(:operation) { '' }
      it 'fails with invalid operation' do
        # operation is nil
        service_object = described_class.new(nil, 10, variant, 10)
        expect(service_object.valid?).to be_falsey
        expect(service_object.errors[:operation]).to include("can't be blank")
        # not a valid operation
        service_object = described_class.new('sum', 10, variant, 10)
        expect(service_object.valid?).to be_falsey
        expect(service_object.errors[:operation]).to include('must be one of add, remove, set')
      end

      it 'fails with invalid quantity' do
        service_object = described_class.new('add', nil, variant, 10)
        expect(service_object.valid?).to be_falsey
        expect(service_object.errors[:quantity]).to include("can't be blank")
      end

      it 'fails with invalid stock_threshold' do
        service_object = described_class.new('add', 10, variant, -10)
        expect(service_object.valid?).to be_falsey
        expect(service_object.errors[:stock_threshold]).to include("must be greater than 0")
      end
    end

    context 'with valid input' do
      it 'fails when result quantity is less than 0' do
        # adding negative quantity
        service_object = described_class.new('add', variant.quantity * -2, variant, 10)
        expect(service_object.save).to be_falsey
        expect(service_object.errors[:quantity]).to include("result quantity cannot be less than zero")

        # subtracting more than variant quantity
        service_object = described_class.new('remove', variant.quantity + 2, variant, 10)
        expect(service_object.save).to be_falsey
        expect(service_object.errors[:quantity]).to include("result quantity cannot be less than zero")
      end

      context 'succssfully updates variant quatity when' do
        it 'adding' do
          service_object = described_class.new('add', 30, variant, 10)
          expect(service_object.save).to be_truthy
          expect(variant.quantity).to equal(variant.previous_quantity + 30)
        end

        it 'removing' do
          service_object = described_class.new('remove', 5, variant, nil)
          expect(service_object.save).to be_truthy
          expect(variant.quantity).to equal(variant.previous_quantity - 5)
          expect(variant.stock_threshold).to eql(nil)
        end

        it 'setting' do
          service_object = described_class.new('set', 50, variant, 10)
          previous_quantity = variant.quantity
          expect(service_object.save).to be_truthy
          expect(variant.previous_quantity).to equal(previous_quantity)
          expect(variant.quantity).to equal(50)
          expect(variant.stock_threshold).to eql(10)
        end
      end
    end
  end
end
