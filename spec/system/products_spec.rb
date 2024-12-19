require 'rails_helper'

RSpec.describe "Product", type: :system do
  let!(:user) { create(:user, :confimed_admin) }

  describe 'Product actions' do
    let!(:products) { create_list(:product_with_variants, 20, user:) }

    before(:each) do
      sign_in(user)
      visit products_path
    end

    it "edits a product name and variant name" do
      product = user.products.order(:created_at).first
      variant = product.variants.order(:created_at).first

      expect(page).to have_css("#product_#{product.id}")
      within "#product_#{product.id}" do
        click_link("Edit")
      end

      expect(page).to have_current_path(edit_product_path(product))
      expect(page).to have_content("Edit #{product.name}")

      fill_in "product[name]", with: "New product name"
      find("input[type='submit']").click

      expect(page).to have_content("Edit New product name")
      within "#product_variant_#{variant.id}" do
        click_button "Edit"
      end
      product.reload
      expect(page).to have_content("Edit variant for #{product.name}")
      within "#edit-product-1-variant-#{variant.id}" do
        # Put invalid attributes
        fill_in "variant[name]", with: "N"
        fill_in "variant[buying_price]", with: 1
        fill_in "variant[supply_price]", with: 1

        find("input[type='submit']").click
        expect(page).to have_content(/is too short \(minimum is 2 characters\)/)
        expect(page).to have_content(/must be in 10..1000000000/)

        # Now add valid attributes
        fill_in "variant[name]", with: "New variant name"
        fill_in "variant[buying_price]", with: 1000
        fill_in "variant[supply_price]", with: 1200

        find("input[type='submit']").click
      end

      expect(page).to have_content("Successfully updated New variant name")
    end

    it "deletes product" do
      product = user.products.order(:created_at).first

      expect(page).to have_css("#product_#{product.id}")
      within "#product_#{product.id}" do
        click_button("Delete")
      end

      accept_alert
      expect(page).to have_no_css("#product_#{product.id}")
    end

    it "deletes product variant" do
      product = user.products.order(:created_at).first
      variant = product.variants.order(:created_at).first

      visit(edit_product_path(product))

      within "#product_variant_#{variant.id}" do
        click_button "Delete"
      end

      accept_alert
      expect(page).to have_no_css("#product_variant_#{variant.id}")
    end

    it 'adds new product' do
      click_button "Product"

      within "#new_product" do
        # Fill wrong attribute
        fill_in "product[name]", with: "L"
        find("input[type='submit']").click
        expect(page).to have_content(/is too short \(minimum is 2 characters\)/)

        # Fill correct attribute
        fill_in "product[name]", with: "Latest product"
        find("input[type='submit']").click
      end

      expect(page).to have_content("Successfully created Latest product")
      expect(page).to have_content("Latest product")
    end

    it "searches product by name" do
      product = products.first
      product.update(name: "Product 1 - name")
      visit products_path

      products.each do |prod|
        expect(page).to have_css("#product_#{prod.id}")
      end

      fill_in "search", with: "Product 1 - name"
      products.each do |prod|
        if prod.id == product.id
          expect(page).to have_css("#product_#{prod.id}")
        else
          expect(page).to have_no_css("#product_#{prod.id}")
        end
      end
    end

    it 'adds new product' do
      product = products.first
      visit edit_product_path(product)

      click_button "Variant"
      expect(page).to have_content("New variant for #{product.name}")
      within "#new-product-1-variant" do
        # Put invalid attributes
        fill_in "variant[name]", with: "N"
        fill_in "variant[buying_price]", with: 1
        fill_in "variant[supply_price]", with: 1

        find("input[type='submit']").click
        expect(page).to have_content(/is too short \(minimum is 2 characters\)/)
        expect(page).to have_content(/must be in 10..1000000000/)

        # Now add valid attributes
        fill_in "variant[name]", with: "New variant name"
        fill_in "variant[buying_price]", with: 1000
        fill_in "variant[supply_price]", with: 1200

        find("input[type='submit']").click
      end

      expect(page).to have_content("Successfully created New variant name")
    end

    context "Item stock" do
      let(:product) { products.first }
      let(:variant) { product.variants.first }
      before(:each) { visit edit_product_path(product) }

      it "Sets new stock for variant" do
        within "#product_variant_#{variant.id}" do
          click_button "Manage Stock"
        end

        expect(page).to have_content("Manage Stock for #{variant.name}")

        within "#edit-variant-#{variant.id}-stock" do
          expect(page).to have_text(variant.quantity)
          check "show_stock_threshold"
          find("input[type='submit']").click

          expect(page).to have_content('must be one of add, remove, set')
          expect(page).to have_content("can't be blank")

          select 'Set to', from: 'operation'
          fill_in "quantity", with: 100
          find("input[type='submit']").click
          expect(page).to have_content("can't be blank")

          uncheck "show_stock_threshold"
          find("input[type='submit']").click
        end
        expect(page).to have_content("Successfully updated #{variant.name}")
      end

      it "Adds stock for variant" do
        within "#product_variant_#{variant.id}" do
          click_button "Manage Stock"
        end

        expect(page).to have_content("Manage Stock for #{variant.name}")

        within "#edit-variant-#{variant.id}-stock" do
          expect(page).to have_text(variant.quantity)

          check "show_stock_threshold"
          select 'Add', from: 'operation'
          fill_in "quantity", with: 100
          fill_in "stock_threshold", with: 5

          expect(page).to have_content(variant.quantity + 100)
          fill_in "quantity", with: 150
          expect(page).to have_content(variant.quantity + 150)

          find("input[type='submit']").click
        end
        expect(page).to have_content("Successfully updated #{variant.name}")
      end

      it "removes stock for variant" do
        within "#product_variant_#{variant.id}" do
          click_button "Manage Stock"
        end

        expect(page).to have_content("Manage Stock for #{variant.name}")

        within "#edit-variant-#{variant.id}-stock" do
          expect(page).to have_text(variant.quantity)

          uncheck "show_stock_threshold"
          select 'Remove', from: 'operation'
          fill_in "quantity", with: 2

          expect(page).to have_content(variant.quantity - 2)
          fill_in "quantity", with: 3
          expect(page).to have_content(variant.quantity - 3)

          find("input[type='submit']").click
        end
        expect(page).to have_content("Successfully updated #{variant.name}")
      end
    end
  end
end
