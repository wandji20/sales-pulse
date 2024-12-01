# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/invite
  def invite(user)
    UserMailer.invite(user, user.generate_token_for(:invitation))
  end
end
