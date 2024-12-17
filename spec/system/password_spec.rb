require 'rails_helper'

RSpec.describe "User Password", type: :system do
  let!(:user) { create(:user, role: 'admin') }

  describe "password reset" do
    it 'redirects to new session path with wrong email' do
      visit login_path
      click_link("Forgot password?")

      expect(page).to have_current_path(new_password_path)
      fill_in "email_address", with: 'awrondaddress@email.com'
      find("input[type='submit']").click

      expect(page).to have_current_path(login_path)
      expect(page).to have_content(/Email not found! Contact your admin to get an invite/)
    end

    it 'creates reset link and redirect to login path' do
      visit login_path
      click_link("Forgot password?")

      expect(page).to have_current_path(new_password_path)
      fill_in "email_address", with: user.email_address
      find("input[type='submit']").click

      expect(page).to have_current_path(login_path)
      expect(page).to have_content(/Password reset successfully sent./)
    end

    it 'saves new password and redirect to login path' do
      visit login_path
      click_link("Forgot password?")

      expect(page).to have_current_path(new_password_path)
      fill_in "email_address", with: user.email_address
      find("input[type='submit']").click

      expect(page).to have_current_path(login_path)
      expect(page).to have_content(/Password reset successfully sent./)

      # Fill invalid password and password confirmation
      token = user.password_reset_token
      visit edit_password_path(token)
      fill_in "Password", with: 'password'
      fill_in "Password confirmation", with: 'passworda'
      find("input[type='submit']").click

      expect(page).to have_current_path(edit_password_path(token))
      expect(page).to have_content(/doesn't match Password/)

      # Now fill correct password and confirmation
      fill_in "Password", with: 'password'
      fill_in "Password confirmation", with: 'password'
      find("input[type='submit']").click
      expect(page).to have_current_path(login_path)
      expect(page).to have_content(/Password has been successfully reset./)
    end
  end
end
