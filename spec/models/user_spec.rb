require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user, role: :admin, confirmed: true) }

  it { should validate_presence_of(:email_address) }
  it { should validate_uniqueness_of(:email_address).case_insensitive }

  it { should validate_presence_of(:password).on(:update) }
  it { should validate_length_of(:password).is_at_least(Constants::MIN_PASSWORD_LENGTH).on(:update) }
  it { should validate_length_of(:password).is_at_most(Constants::MAX_PASSWORD_LENGTH).on(:update) }
  it { should validate_confirmation_of(:password) }

  it { should validate_uniqueness_of(:telephone).case_insensitive }

  it { should have_one_attached(:avatar) }
  it { should have_many(:products) }
  it { should belong_to(:supplier).optional.class_name("User") }
  it { should have_many(:customers).class_name("User") }

  describe "validating format" do
    context 'email address' do
      context 'bad format' do
        subject { build(:user, email_address: 'some') }
        it 'fails with invalid email' do
          expect(subject.valid?).to be(false)
          expect(subject.errors.full_messages).to include(/Email address is invalid/)
        end
      end

      context 'correct format' do
        subject { build(:user, email_address: 'some@email.com') }
        it 'accepts correct email' do
          expect(subject.valid?).to be(true)
          expect(subject.errors.full_messages).to_not include(/Email address is invalid/)
        end
      end
    end
  end

  describe "validating format" do
    context 'telephone' do
      context 'bad format' do
        subject { build(:user, telephone: '124587') }
        it 'fails with invalid telephone' do
          expect(subject.valid?).to be(false)
          expect(subject.errors.full_messages).to include(/Telephone is invalid/)
        end
      end

      context 'correct format' do
        subject { build(:user, telephone: '123654789') }
        it 'accepts correct telephone' do
          expect(subject.valid?).to be(true)
          expect(subject.errors.full_messages).to_not include(/Telephone is invalid/)
        end
      end

      context 'correct format with invalid start and end characters' do
        subject { build(:user, telephone: '~123654789!') }
        it 'fails with invalid telephone' do
          expect(subject.valid?).to be(false)
          expect(subject.errors.full_messages).to include(/Telephone is invalid/)
        end
      end
    end
  end

  describe "#invite_user" do
    let(:user) { create(:user, role: 'admin', confirmed: true) }

    it "invites new user" do
      new_user = user.invite_user('one@email.com')
      expect(new_user.persisted?).to be_truthy
    end

    it "resends new user invite if user is unconfirmed" do
      create(:user, email_address: "one@email.com")

      new_user = user.invite_user('one@email.com')
      expect(new_user.persisted?).to be_truthy
    end

    it "fails to invite new user with confirmed email" do
      create(:user, email_address: "one@email.com", confirmed: true)

      new_user = user.invite_user('one@email.com')
      expect(new_user.persisted?).to be_falsey
      expect(new_user.errors.messages[:email_address]).to include(/has already been taken/)
    end
  end
end
