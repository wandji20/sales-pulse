require 'rails_helper'

RSpec.describe "Record", type: :system do
  let!(:user) { create(:user, :confimed_admin) }
  let!(:products) { create_list(:product_with_variants, 10, user:) }
  let!(:customers) {  create_list(:user, 20, supplier: user) }
  let!(:service_items) { create_list(:service_item, 20, user:) }

  describe 'record actions' do
    before(:each) do
      sign_in(user)
      visit root_path
    end

    describe "sale actions" do
      before(:each) { click_button "Sale" }

      context "filters" do
        it 'filters products items' do
          Variant.first.update(name: "zzIphone chargers")

          within "#record_variant_id" do
            click_button "Open dropdown"
            expect(page).to have_no_content("zzIphone chargers")

            fill_in "search", with: "zzIph"
            expect(page).to have_content("zzIphone chargers")

            check "zzIphone chargers"
            expect(page).to have_field('search', with: "zzIphone chargers")
          end
        end

        it 'filters customers' do
          user.customers.first.update(full_name: "zzz last name")
          within "#record_customer_id" do
            click_button "Open dropdown"

            expect(page).to have_no_content("zzz last name")
            fill_in "search", with: "zzz"
            expect(page).to have_content("zzz last name")

            check "zzz last name"
            expect(page).to have_field('search', with: "zzz last name")
          end
        end
      end

      context "create" do
        it "adds sale without customer" do
          variant = Variant.order(:name).first

          within "#new_record" do
            # Submit with errors
            find("input[type='submit']").click
            expect(page).to have_content("can't be blank")
            expect(page).to have_content("is not a number")

            # Fix variant error and submit with errors
            within "#record_variant_id" do
              click_button "Open dropdown"
              check variant.name
            end
            find("input[type='submit']").click
            expect(page).to have_content("can't be blank")
            expect(page).to have_content("is not a number")

            # Fix price error and submit with errors
            fill_in "record[unit_price]", with: 1000
            find("input[type='submit']").click
            expect(page).to have_content("can't be blank")
            expect(page).to have_no_content("is not a number")

            # Fix category error and submit without errors
            choose "Supply"
            find("input[type='submit']").click
          end

          expect(page).to have_content("Successfully added supply record for #{variant.name}")
        end

        it "adds sale with new customer" do
          variant = Variant.order(:name).first

          within "#new_record" do
            within "#record_variant_id" do
              click_button "Open dropdown"
              check variant.name
            end

            fill_in "record[unit_price]", with: 1000

            choose "Supply"
            click_button "Add new customer instead?"
            fill_in "customer[full_name]", with: "W"
            find("input[type='submit']").click

            expect(page).to have_content("can't be blank")
            expect(page).to have_content("is too short (minimum is 2 characters)")

            fill_in "customer[full_name]", with: "William Jones"
            fill_in "customer[telephone]", with: "697845214"
            find("input[type='submit']").click
          end

          expect(page).to have_content("Successfully added supply record for #{variant.name}")
        end

        it "adds sale with existing customer" do
          variant = Variant.order(:name).first
          customer = user.customers.order(:full_name).first

          within "#new_record" do
            within "#record_variant_id" do
              click_button "Open dropdown"
              check variant.name
            end

            fill_in "record[unit_price]", with: 1000

            choose "Retail"
            within "#record_customer_id" do
              click_button "Open dropdown"
              check customer.full_name
            end
            find("input[type='submit']").click
          end

          expect(page).to have_content("Successfully added retail record for #{variant.name}")
        end
      end
    end

    describe 'service actions' do
      before(:each) { click_button "Service" }

      it 'filters service items' do
        ServiceItem.first.update(name: "zzz service")

        within "#record_service_item_id" do
          click_button "Open dropdown"
          expect(page).to have_no_content("zzz service")

          fill_in "search", with: "zz"
          expect(page).to have_content("zzz service")

          check "zzz service"
          expect(page).to have_field('search', with: "zzz service")
        end
      end

      it "adds new record with existing service item" do
        item = user.service_items.order(:name).first

        within "#new_record" do
          find("input[type='submit']").click
          expect(page).to have_content("can't be blank")
          expect(page).to have_content("is not a number")

          within "#record_service_item_id" do
            click_button "Open dropdown"
            check item.name
          end

          fill_in "record[unit_price]", with: 1000

          choose "Unpaid"
          find("input[type='submit']").click
        end

        expect(page).to have_content("Successfully added service record for #{item.name}")
      end

      it "adds new record with new service item" do
        within "#new_record" do
          fill_in "record[unit_price]", with: 1000

          click_button "Add service item instead?"
          fill_in "service_item[name]", with: "A"
          find("input[type='submit']").click

          expect(page).to have_content("is too short (minimum is 2 characters)")

          choose "Unpaid"
          fill_in "service_item[name]", with: "Another"
          find("input[type='submit']").click
        end

        expect(page).to have_content("Successfully added service record for Another")
      end
    end

    describe "manage record" do
      let!(:sale) { create(:record, user:) }
      let!(:service) { create(:record, category: 'service', user:) }
      before(:each) { visit root_path }

      it 'reverts a service record' do
        within "tr#record_#{service.id}" do
          expect(page).to have_no_content("Delete")
          expect(page).to have_content("Revert")

          click_button("Revert")
        end

        accept_alert
        expect(page).to have_content("Successfully revert #{service.category} record for #{service.name}")
        within "tr#record_#{service.id}" do
          expect(page).to have_content("Delete")
          expect(page).to have_content("Revert")
        end
      end

      it 'reverts a sale record' do
        within "tr#record_#{sale.id}" do
          expect(page).to have_no_content("Delete")
          expect(page).to have_content("Revert")

          click_button("Revert")
        end

        accept_alert
        expect(page).to have_content("Successfully revert #{sale.category} record for #{sale.name}")
        within "tr#record_#{sale.id}" do
          expect(page).to have_content("Delete")
          expect(page).to have_content("Revert")
        end
      end

      it 'edits a service record' do
        within "tr#record_#{sale.id}" do
          expect(page).to have_content(sale.unit_price)
          click_button("Edit")
        end

        fill_in "record[unit_price]", with: 1000
        choose "Unpaid"
        choose "Supply"
        find("input[type='submit']").click

        expect(page).to have_content("Successfully updated supply record for #{sale.name}")
        within "tr#record_#{sale.id}" do
          expect(page).to have_no_content(sale.unit_price)
          expect(page).to have_content("1000")
        end
      end

      it 'edits a sale record' do
        within "tr#record_#{sale.id}" do
          expect(page).to have_content(sale.unit_price)
          click_button("Edit")
        end

        fill_in "record[unit_price]", with: 2000
        choose "Unpaid"
        choose "Supply"
        find("input[type='submit']").click

        expect(page).to have_content("Successfully updated supply record for #{sale.name}")
        within "tr#record_#{sale.id}" do
          expect(page).to have_no_content(sale.unit_price)
          expect(page).to have_content("2000")
        end
      end

      it 'deletes a reverted service record' do
        within "tr#record_#{service.id}" do
          expect(page).to have_no_content("Delete")
          click_button("Revert")
        end
        accept_alert

        within "tr#record_#{service.id}" do
          click_button("Delete")
        end

        accept_alert
        expect(page).to have_content("Successfully deleted #{service.category} record for #{service.name}")
      end

      it 'deletes a reverted sale record' do
        within "tr#record_#{sale.id}" do
          expect(page).to have_no_content("Delete")
          click_button("Revert")
        end
        accept_alert

        within "tr#record_#{sale.id}" do
          click_button("Delete")
        end

        accept_alert
        expect(page).to have_content("Successfully deleted #{sale.category} record for #{sale.name}")
      end
    end
  end
end
