require 'rails_helper'

RSpec.describe "Customer", type: :system do
  let!(:user) { create(:user, :confimed_admin) }
  let!(:customers) { create_list(:user, 20, supplier: user) }

  describe 'customer actions' do
    before(:each) do
      sign_in(user)
      visit customers_path
    end

    it "searches customers by full_name" do
      customer = customers.first
      customer.update(full_name: "My full names")

      customers.each do |cus|
        expect(page).to have_css("#customer_user_#{cus.id}")
      end

      fill_in "search", with: "My full names"
      customers.each do |cus|
        if cus.id == customer.id
          expect(page).to have_css("#customer_user_#{cus.id}")
        else
          expect(page).to have_no_css("#customer_user_#{cus.id}")
        end
      end
    end

    it 'adds new customer' do
      click_button "Customer"
      expect(page).to have_content("Create new customer")
      within "#customer-form" do
        # Put invalid attributes
        fill_in "user[full_name]", with: "N"
        fill_in "user[telephone]", with: "23"

        find("input[type='submit']").click
        expect(page).to have_content(/is too short \(minimum is 2 characters\)/)
        expect(page).to have_content(/is invalid/)

        # Now add valid attributes
        fill_in "user[full_name]", with: "New customer name"
        fill_in "user[email_address]", with: "customer@email.com"
        fill_in "user[telephone]", with: "678451258"

        find("input[type='submit']").click
      end

      expect(page).to have_no_content("Create new customer")
      within "table" do
        expect(page).to have_content("customer@email.com")
        expect(page).to have_content("New customer name")
        expect(page).to have_content("678451258")
      end
    end

    it "edit customer" do
      customer = user.customers.order(:created_at).first

      within "tr#customer_user_#{customer.id}" do
        click_button "Edit"
      end

      within "#customer-form" do
        # Put invalid attributes
        fill_in "user[full_name]", with: "N"
        fill_in "user[telephone]", with: "23"

        find("input[type='submit']").click
        expect(page).to have_content(/is too short \(minimum is 2 characters\)/)
        expect(page).to have_content(/is invalid/)

        # Now add valid attributes
        fill_in "user[full_name]", with: "Updated customer name"
        fill_in "user[email_address]", with: "updatedcustomer@email.com"
        fill_in "user[telephone]", with: "678451223"

        find("input[type='submit']").click
      end

      within "tr#customer_user_#{customer.id}" do
        expect(page).to have_content("updatedcustomer@email.com")
        expect(page).to have_content("Updated customer name")
        expect(page).to have_content("678451223")
      end
    end

    it "archive customer" do
      customer = user.customers.order(:created_at).first

      within "#customer_user_#{customer.id}" do
        click_button "Archive"
      end

      accept_alert
      expect(page).to have_no_css("#customer_user_#{customer.id}")
    end
  end
end
