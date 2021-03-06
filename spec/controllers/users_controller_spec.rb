require 'rails_helper'

describe UsersController do
  describe 'GET new' do
    before :each do
      get :new
    end

    it 'assigns a new user' do
      expect(assigns[:user]).to be_a(User)
      expect(assigns[:user]).to be_new_record
    end

    it 'builds a new link' do
      expect(assigns[:user].links.length).to eql(1)
      expect(assigns[:user].links.last).to be_new_record
    end

    it 'assigns a new TempImage for the file uploader' do
      expect(assigns[:temp_image]).to be_new_record
      expect(assigns[:temp_image]).to be_a(TempImage)
    end

    it 'renders the signup page' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    let(:user_params) {{
      first_name:            'Bobby',
      last_name:             'Tables',
      screen_name:           'little_bobby_tables',
      email:                 'bobby@example.com',
      password:              's3cr3t',
      password_confirmation: 's3cr3t',
      accepted_t_and_c:      true,
      description:           "I am a fabricated user."
    }}
    let(:stub_user)   { Fabricate.build(:user) }
    let(:saved)       { true }

    before :each do
      allow(User).to receive(:new).and_return(stub_user)
      allow(stub_user).to receive(:save).and_return(saved)
      post :create, user: user_params
    end

    it 'builds a new user' do
      expect(User).to have_received(:new).with(user_params)
    end

    it 'saves the user' do
      expect(stub_user).to have_received(:save)
    end

    context 'when successful' do
      let(:saved) { true }

      it 'sets a flash notice' do
        expect(flash[:notice]).to eql('Please click the link in the activation email we have just sent in order to continue.')
      end

      it 'redirects to the root page' do
        expect(response).to redirect_to(:root)
      end
    end

    context 'when unsuccessful' do
      let(:saved) { false }

      it 'builds a new link' do
        expect(assigns[:user].links.length).to eql(1)
        expect(assigns[:user].links.last).to be_new_record
      end

      it 'assigns a new TempImage for the file uploader' do
        expect(assigns[:temp_image]).to be_new_record
        expect(assigns[:temp_image]).to be_a(TempImage)
      end

      it 'renders the new page' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET activate' do
    let(:user)       { Fabricate.build(:pending_user) }
    let(:successful) { true }

    before :each do
      allow(User).to receive(:load_from_activation_token).and_return(user)
      allow(user).to receive(:activate!).and_return(successful)
      get :activate, id: '123abc'
    end

    it 'fetches the user' do
      expect(User).to have_received(:load_from_activation_token).with('123abc')
    end

    it 'assigns the user' do
      expect(assigns[:user]).to eql(user)
    end

    context 'when successful' do
      let(:successful) { true }

      it 'activates the user' do
        expect(user).to have_received(:activate!)
      end

      it 'redirects to the sign in page' do
        expect(response).to redirect_to(:signin)
      end

      it 'displays a success notice' do
        expect(flash[:notice]).to eq('You have successfully activated your account. Please sign in.')
      end
    end

    context 'when not successful' do
      let(:successful) { false }

      it 'is not authenticated' do
        expect(response.status).to eql(302)
      end
    end
  end

  describe 'GET resend_activation_email' do
    let(:user)          { Fabricate(:user, id: 123) }
    let(:is_pending)    { true }
    let(:mailer_double) { double(AuthenticationMailer) }

    before :each do
      @user = user
      login_user
      allow(user).to receive(:pending?).and_return(is_pending)

      allow(AuthenticationMailer).to receive(:activation_needed_email).with(user).and_return(mailer_double)
      allow(mailer_double).to receive(:deliver)

      get :resend_activation_email
    end

    it 'checks to see if the current user needs to be activated' do
      expect(user).to have_received(:pending?)
    end

    context 'when the user needs to be activated' do
      let(:is_pending)    { true }

      it 'resends the activation email' do
        expect(mailer_double).to have_received(:deliver)
      end

      it 'redirects to the root page' do
        expect(response).to redirect_to(:root)
      end

      it 'gives the user the instructions for what will happen next' do
        expect(flash[:notice]).to eql('We have resent your activation email. Please check you spam filter if it has still not appeared within the next hour.')
      end
    end

    context 'when the user does not need to be activated' do
      let(:is_pending) { false }

      it 'does not resend the activation email' do
        expect(AuthenticationMailer).not_to have_received(:activation_needed_email)
      end

      it 'redirects to the root page' do
        expect(response).to redirect_to(:root)
      end

      it 'gives the user an error' do
        expect(flash[:alert]).to eql('It does not look like you need to be activated.')
      end
    end
  end
end
