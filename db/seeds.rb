# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
def create_user
  User.create!(email_address: 'admin@email.com',
  password: 'password', password_confirmation: 'password',
  telephone: '678163222', role: 1, confirmed: true)
end

def create_products_and_variants
  admin = User.admin.first
  20.times do |n|
   product = admin.products.create!(name: "#{Faker::Appliance.brand} - #{n + 1}")

    (6..15).to_a.sample.times do |n|
      buying_price = (2..10).to_a.sample * 1000
      supply_price = [ 100, 200, 300, 400, 500 ].sample
      stock_threshold = [ nil, 6, 10, 5 ].sample
      product.variants.create!(name: "#{Faker::Appliance.equipment} - #{n + 1}",
      buying_price:, supply_price:, stock_threshold:, quantity: (10..20).to_a.sample)
    end
  end
end

def create_sales_and_services
  admin = User.admin.first

  Variant.where("quantity > ?", 20).each do |variant|
    unit_price = ((variant.supply_price.to_i..variant.supply_price.to_i * 1.5).to_a.sample / 10) * 10
    status = variant.id % 5 == 0 ? :paid : :unpaid
    quantity = (1..20).to_a.sample
    category = [ 'supply', 'retail' ].sample
    admin.records.add_record(unit_price:, category:, variant:, quantity:, status:)
  end

  Variant.where("quantity > ?", 10).each do |variant|
    unit_price = ((variant.supply_price.to_i..variant.supply_price.to_i * 1.5).to_a.sample / 10) * 10
    status = variant.id % 5 == 0 ? :paid : :unpaid
    quantity = (1..10).to_a.sample
    category = [ 'supply', 'retail' ].sample
    admin.records.add_record(unit_price:, category:, variant:, quantity:, status:)
  end

  Variant.where("quantity > ?", 5).each do |variant|
    unit_price = ((variant.supply_price.to_i..variant.supply_price.to_i * 1.5).to_a.sample / 10) * 10
    status = variant.id % 5 == 0 ? :paid : :unpaid
    quantity = (1..5).to_a.sample
    category = [ 'supply', 'retail' ].sample
    admin.records.add_record(unit_price:, category:, variant:, quantity:, status:)
  end

  [ "Phone sale", "Media transfers" ].each do |name|
    admin.service_items.create!(name:, description: Faker::Lorem.words(number: 20))
  end

  # create service records
  admin.service_items.each do |service_item|
    admin.records.add_record({ quantity: 1, unit_price: [ 1000, 2000 ].sample,
                                category: 'service', service_item_id: service_item.id })
  end

  # revert a some sales
  admin.records.where('quantity < ?', 5).take(4).each(&:revert_sale)
end

User.destroy_all
Product.destroy_all
Record.destroy_all
ServiceItem.destroy_all

p 'Creating admin user'
create_user
p 'Creating products and variants'
create_products_and_variants
p "Creating sales and services"
create_sales_and_services
