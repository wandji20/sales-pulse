module AuthenticationHelper
  def sign_in(user)
    if respond_to?(:visit) # System specs
      visit login_path
      fill_in "Email", with: user.email_address
      fill_in "Password", with: user.password
      find("input[type='submit']").click

      expect(page).to_not have_current_path(login_path)
    else # Controller specs
      session[:user_id] = user.id
    end
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :system
  config.include AuthenticationHelper, type: :controller
end
