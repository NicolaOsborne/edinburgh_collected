require 'rails_helper'

describe SessionsController do
  describe 'GET new' do
    it 'renders the login page' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    let(:token) { 't0k3n' }
    let(:login_params) {{
      username: 'bobby',
      password: 's3cr3t'
    }}

    before :each do
      allow(SessionWrapper).to receive(:create).and_return(token)
      post :create, login_params
    end

    it 'logs the user in' do
      expect(SessionWrapper).to have_received(:create).with('bobby', 's3cr3t')
    end

    context 'when successful' do
      let(:token) { 't0k3n' }

      it 'has a session token' do
        expect(session[:auth_token]).to eql(token)
      end

      it 'redirects to the root page' do
        expect(response).to redirect_to(:root)
      end

      it 'displays a success notice' do
        expect(flash[:notice]).to eql('Successfully logged in')
      end
    end

    context 'when unsuccessful' do
      let(:token) { '' }

      it 'does not have a session token' do
        expect(session[:auth_token]).to be_blank
      end

      it 'redirects to the login page' do
        expect(response).to redirect_to(:login)
      end

      it 'displays a failure alert' do
        expect(flash[:alert]).to eql('Could not log in')
      end
    end
  end
end