require 'rails_helper'

RSpec.describe "User Invitation", type: :system do
  let!(:user) { create(:user, role: 'admin') }

  describe "login" do
    it 'fails to login with unconfirmed email address' do
      visit login_path
      fill_in "Email", with: user.email_address
      fill_in "Password", with: user.password
      find("input[type='submit']").click

      expect(page).to have_current_path(login_path)
      expect(page).to have_content(/Please confirm your account to continue./)
    end

    it 'signs in confimed user and redirect to root path' do
      user.update(confirmed: true)

      visit login_path
      fill_in "Email", with: user.email_address
      fill_in "Password", with: user.password
      find("input[type='submit']").click

      expect(page).to have_current_path(root_path)
      expect(page).to have_no_content(/Wrong email address or password./)
      expect(page).to have_no_content(/Please confirm your account to continue./)
    end
  end

  describe "invite user" do
    let!(:user) { create(:user, role: 'admin', confirmed: true) }
    before(:each) do
      sign_in(user)
      visit account_path
    end

    it 'invites new user' do
      click_button "Invite user"

      within "form#new-user-form" do
        fill_in "Email", with: "newuser@email.com"
        find("input[type='submit']").click
      end

      expect(page).to have_current_path(account_path)
      expect(page).to have_content(/An invitation email has been sent to newuser@email.com./)
    end

    it 're-invites unconfirmed user' do
      new_user = create(:user, role: 'admin')

      click_button "Invite user"

      within "form#new-user-form" do
        fill_in "Email", with: new_user.email_address
        find("input[type='submit']").click
      end

      expect(page).to have_current_path(account_path)
      expect(page).to have_content("An invitation email has been sent to #{new_user.email_address}.")
    end

    it "fails to invite user with confirmed enail address" do
      new_user = create(:user, role: 'admin', confirmed: true)

      click_button "Invite user"

      within "form#new-user-form" do
        fill_in "Email", with: new_user.email_address
        find("input[type='submit']").click
      end

      expect(page).to have_current_path(account_path)
      expect(page).to have_content(/has already been taken/)
      expect(page).to have_no_content("An invitation email has been sent to #{new_user.email_address}.")
    end
  end

  describe "accept invitation" do
    let!(:user) { create(:user, role: 'admin', confirmed: true) }
    before(:each) do
      sign_in(user)
      visit account_path
    end

    it 'saves user with valid password' do
      click_button "Invite user"

      within "form#new-user-form" do
        fill_in "Email", with: "newuser@email.com"
        find("input[type='submit']").click
      end

      expect(page).to have_content(/An invitation email has been sent to newuser@email.com./)

      # close alert to access nav
      within '#flash-notifications' do
        click_button 'Close'
      end
      # logout current user
      within "nav.fixed.top-0" do
        click_button "user-menu-button"
        click_button "Log out"
      end

      expect(page).to have_current_path(login_path)

      # Fill invalid password and password confirmation
      new_user = User.find_by(email_address: "newuser@email.com")
      token = new_user.generate_token_for(:invitation)

      visit edit_user_invitation_path(id: new_user.id, token:)
      fill_in "Password", with: 'password'
      fill_in "Password confirmation", with: 'passworda'
      find("input[type='submit']").click

      expect(page).to have_current_path(edit_user_invitation_path(id: new_user.id, token:))
      expect(page).to have_content(/doesn't match Password/)

      # Now fill correct password and confirmation
      fill_in "Password", with: 'password'
      fill_in "Password confirmation", with: 'password'
      find("input[type='submit']").click
      expect(page).to have_current_path(root_path)
      expect(page).to have_content(/You invitation was successfully accepted/)
    end
  end
end
