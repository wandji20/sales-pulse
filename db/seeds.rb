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
  User.create(email_address: 'admin@email.com',
  password: 'password', password_confirmation: 'password',
  telephone: '678163222', role: 1)
end

def create_products_and_variants
  20.times do |n|
   product = User.admin.first.products.create!(name: "#{Faker::Appliance.brand} - #{n + 1}")

    (6..15).to_a.sample.times do |n|
      product.variants.create!(name: "#{Faker::Appliance.equipment} - #{n + 1}",
      price: (2..10).to_a.sample * 1000, quantity: (10..20).to_a.sample)
    end
  end
end

User.destroy_all
Product.destroy_all

p 'Creating admin user'
create_user
p 'Creating products and variants'
create_products_and_variants
