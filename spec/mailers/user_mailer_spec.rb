require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "invite" do
    let(:user) { create(:user, role: 'admin') }
    let(:mail) { UserMailer.invite(user, user.generate_token_for(:invitation)) }

    it "renders the headers" do
      expect(mail.subject).to eq("Invitation to join Sales Pulse")
      expect(mail.to).to eq([ user.email_address ])
      expect(mail.from).to eq([ "from@example.com" ])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("You can accept your invitation within the next one week on")
    end
  end
end
