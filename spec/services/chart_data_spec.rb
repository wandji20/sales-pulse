require 'rails_helper'

RSpec.describe ChartData, type: :model do
  let(:user) { create(:user) }

  describe '#call' do
    let!(:supply_records) { create_list(:record, 20, user:, category: "supply", created_at: DateTime.current + ((-10..30).to_a.sample).days) }
    let!(:retail_records) { create_list(:record, 20, user:, category: "retail", created_at: DateTime.current + ((-10..30).to_a.sample).days) }

    context "returns correct data" do
      it 'when params is empty' do
        params = {}
        chart_data = ChartData.call(params, user)
        # call this to create records

        expect(chart_data[:pie_data]).to all(
          a_hash_including(
            "category" => a_kind_of(String),
            "total_quantity" => a_kind_of(Integer),
            "total_price" => a_kind_of(Float),
          )
        )

        expect(chart_data[:bar_data]).to all(
          a_hash_including(
            "name" => a_kind_of(String),
            "product_id" => a_kind_of(Integer),
            "total_price" => a_kind_of(Float),
            "total_quantity" => a_kind_of(Integer),
          )
        )
      end

      it 'for today' do
        create_list(:record, 3, user:, category: "supply")
        params = { period: 'today' }
        chart_data = ChartData.call(params, user)

        expect(chart_data[:pie_data]).to all(
          a_hash_including(
            "category" => a_kind_of(String),
            "total_quantity" => a_kind_of(Integer),
            "total_price" => a_kind_of(Float),
          )
        )

        expect(chart_data[:bar_data]).to all(
          a_hash_including(
            "name" => a_kind_of(String),
            "product_id" => a_kind_of(Integer),
            "total_price" => a_kind_of(Float),
            "total_quantity" => a_kind_of(Integer),
          )
        )
      end

      it 'for this week' do
        params = { period: 'week' }
        create_list(:record, 5, user:, category: "supply")
        chart_data = ChartData.call(params, user)

        expect(chart_data[:pie_data]).to all(
          a_hash_including(
            "category" => a_kind_of(String),
            "total_quantity" => a_kind_of(Integer),
            "total_price" => a_kind_of(Float),
          )
        )

        expect(chart_data[:bar_data]).to all(
          a_hash_including(
            "name" => a_kind_of(String),
            "product_id" => a_kind_of(Integer),
            "total_price" => a_kind_of(Float),
            "total_quantity" => a_kind_of(Integer),
          )
        )
      end

      it 'for this month' do
        params = { period: 'month' }
        chart_data = ChartData.call(params, user)

        expect(chart_data[:pie_data]).to all(
          a_hash_including(
            "category" => a_kind_of(String),
            "total_quantity" => a_kind_of(Integer),
            "total_price" => a_kind_of(Float),
          )
        )

        expect(chart_data[:bar_data]).to all(
          a_hash_including(
            "name" => a_kind_of(String),
            "product_id" => a_kind_of(Integer),
            "total_price" => a_kind_of(Float),
            "total_quantity" => a_kind_of(Integer),
          )
        )
      end

      it 'for custom period' do
        params = { period: 'custom', interval: "#{(DateTime.current - 30.days).strftime("%d-%b-%Y")} to #{(DateTime.current + 30.days).strftime("%d-%b-%Y")}" }
        chart_data = ChartData.call(params, user)

        expect(chart_data[:pie_data]).to all(
          a_hash_including(
            "category" => a_kind_of(String),
            "total_quantity" => a_kind_of(Integer),
            "total_price" => a_kind_of(Float),
          )
        )

        expect(chart_data[:bar_data]).to all(
          a_hash_including(
            "name" => a_kind_of(String),
            "product_id" => a_kind_of(Integer),
            "total_price" => a_kind_of(Float),
            "total_quantity" => a_kind_of(Integer),
          )
        )
      end
    end
  end
end
