require 'rails_helper'

RSpec.describe "User Session", type: :system do
  let!(:user) { create(:user, role: 'admin', confirmed: true) }

  describe "login" do
    it 'displays flash error with wrong user credential' do
      visit login_path
      fill_in "Email", with: user.email_address
      fill_in "Password", with: 'a wrong password'
      find("input[type='submit']").click

      expect(page).to have_current_path(login_path)
      expect(page).to have_content(/Invalid email or password./)
    end

    it 'signs in user and redirect to root path' do
      visit login_path
      fill_in "Email", with: user.email_address
      fill_in "Password", with: user.password
      find("input[type='submit']").click

      expect(page).to have_current_path(root_path)
      expect(page).to have_no_content(/Wrong email address or password./)
    end

    it "redirects to login path is no user session" do
      %w[Records Dashboard Products Customers].each do |link|
        visit login_path

        click_link link
        expect(page).to have_current_path(login_path)
      end
    end
  end

  describe "logout" do
    it 'logs out sign in user' do
      %w[Records Dashboard Products Customers].each do |link|
        sign_in(user)

        click_link link
        expect(page).to have_current_path("/#{link.downcase}")

        within "nav.fixed.top-0" do
          click_button "user-menu-button"
          click_button "Log out"
        end

        expect(page).to have_current_path(login_path)
      end
    end
  end
end
