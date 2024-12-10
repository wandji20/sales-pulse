class UserMailer < ApplicationMailer
  def invite(user, token)
    @token = token
    @user = user
    mail subject: t(".subject"), to: user.email_address
  end
end
