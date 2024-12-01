class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: t("password_mailer.subject"), to: user.email_address
  end
end
