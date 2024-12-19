require 'rails_helper'

RSpec.describe "User Account", type: :system do
  let!(:user) { create(:user, role: 'admin', confirmed: true) }

  describe 'account update' do
    before(:each) do
      sign_in(user)
      visit account_path
    end

    it 'updates user name and avatar' do
      expect(find("input[name='user[full_name]']").value).to eq(user.full_name)
      # Input invalid full name
      fill_in 'user[full_name]', with: 's'
      find("input[type='submit']").click
      expect(page).to have_content(/is too short \(minimum is 2 characters\)/)

      # Input valid name
      fill_in 'user[full_name]', with: 'New name'
      find("input[type='submit']").click

      expect(find("input[name='user[full_name]']").value).to eq('New name')
      expect(page).to have_content(/Successfully updated my account/)
    end

    it 'toggles notication settings' do
      expect(page).to have_css('button.enabled#low-stock-reminder')
      click_button 'low-stock-reminder'
      expect(page).to have_css('button.disabled#low-stock-reminder')
      expect(page).to have_content(/Successfully updated setting/)

      expect(page).to have_css('button.enabled#end-of-day-sales')
      click_button 'end-of-day-sales'
      expect(page).to have_css('button.disabled#end-of-day-sales')
      expect(page).to have_content(/Successfully updated setting/)

      expect(page).to have_css('button.disabled#show-profit-on-sales')
      click_button 'show-profit-on-sales'
      expect(page).to have_css('button.enabled#show-profit-on-sales')
      expect(page).to have_content(/Successfully updated setting/)
    end
  end
end
