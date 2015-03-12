require 'rails_helper'

describe Admin::Moderation::ScrapbooksController do
  it 'requires the user to be authenticated as an administrator' do
    expect(subject).to be_a(Admin::AuthenticatedAdminController)
  end

  describe 'GET index' do
    let(:unmoderated_scrapbooks) { Array.new(2) {|i| Fabricate.build(:scrapbook, id: i+1)} }

    context 'when not logged in' do
      before :each do
        get :index
      end

      it 'does not store the moderated path' do
        expect(session[:current_scrapbook_index_path]).to be_nil
      end

      it 'redirects to sign in' do
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'when logged in but not as an admin' do
      before :each do
        @user = Fabricate(:active_user)
        login_user
        get :index
      end

      it 'does not store the moderated path' do
        expect(session[:current_scrapbook_index_path]).to be_nil
      end

      it 'redirects to sign in' do
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'when logged in' do
      before :each do
        @user = Fabricate(:admin_user)
        login_user
        allow(Scrapbook).to receive(:unmoderated).and_return(unmoderated_scrapbooks)
        get :index
      end

      it 'stores the index path' do
        expect(session[:current_scrapbook_index_path]).to eql(admin_moderation_scrapbooks_path)
      end

      it 'fetches all items that need to be moderated' do
        expect(Scrapbook).to have_received(:unmoderated)
      end

      it 'assigns the unmoderated items' do
        expect(assigns[:items]).to eql(unmoderated_scrapbooks)
      end

      it 'renders the index view' do
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET moderated' do
    let(:moderated_scrapbooks) { double('moderated_scrapbooks') }
    let(:ordered_scrapbooks)   { double('ordered_scrapbooks') }

    context 'when not logged in' do
      before :each do
        get :moderated
      end

      it 'does not store the moderated path' do
        expect(session[:current_scrapbook_index_path]).to be_nil
      end

      it 'redirects to sign in' do
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'when logged in but not as an admin' do
      before :each do
        @user = Fabricate(:active_user)
        login_user
        get :moderated
      end

      it 'does not store the moderated path' do
        expect(session[:current_scrapbook_index_path]).to be_nil
      end

      it 'redirects to sign in' do
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'when logged in' do
      before :each do
        @user = Fabricate(:admin_user)
        login_user
        allow(Scrapbook).to receive(:moderated).and_return(moderated_scrapbooks)
        allow(moderated_scrapbooks).to receive(:by_recent).and_return(ordered_scrapbooks)
        get :moderated
      end

      it 'stores the moderated path' do
        expect(session[:current_scrapbook_index_path]).to eql(moderated_admin_moderation_scrapbooks_path)
      end

      it 'fetches all items that need to be moderated' do
        expect(Scrapbook).to have_received(:moderated)
      end

      it 'sorts the items with newest first' do
        expect(moderated_scrapbooks).to have_received(:by_recent)
      end

      it 'assigns the sorted items' do
        expect(assigns[:items]).to eql(ordered_scrapbooks)
      end

      it 'renders the index view' do
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET show' do
    let(:scrapbook) { Fabricate.build(:scrapbook, id: 123) }

    context 'when not logged in' do
      it 'redirects to sign in' do
        get :show, id: scrapbook.id
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'when logged in but not as an admin' do
      it 'redirects to sign in' do
        @user = Fabricate(:active_user)
        login_user
        get :show, id: scrapbook.id
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'when logged in' do
      before :each do
        @user = Fabricate(:admin_user)
        login_user
      end

      it 'looks for the requested scrapbook' do
        allow(Scrapbook).to receive(:find).with(scrapbook.to_param).and_return(scrapbook)
        get :show, id: scrapbook.id
        expect(Scrapbook).to have_received(:find).with(scrapbook.to_param)
      end

      context "when scrapbook is found" do
        let(:memories)           { double('scrapbook memories') }
        let(:paginated_memories) { double('paginated memories') }

        before :each do
          allow(Scrapbook).to receive(:find).with(scrapbook.to_param).and_return(scrapbook)
          allow(scrapbook).to receive(:ordered_memories).and_return(memories)
          allow(Kaminari).to receive(:paginate_array).and_return(paginated_memories)
          allow(paginated_memories).to receive(:page).and_return(paginated_memories)
          get :show, id: scrapbook.id
        end

        it "assigns the scrapbook" do
          expect(assigns[:scrapbook]).to eql(scrapbook)
        end

        it "fetches the scrapbook's memories in the correct order" do
          expect(scrapbook).to have_received(:ordered_memories)
        end

        it "paginates the memories" do
          expect(Kaminari).to have_received(:paginate_array).with(memories)
          expect(paginated_memories).to have_received(:page)
        end

        it "assigns the paginated memories" do
          expect(assigns[:memories]).to eql(paginated_memories)
        end

        it 'renders the show page' do
          expect(response).to render_template(:show)
        end

        it 'has a 200 status' do
          expect(response.status).to eql(200)
        end
      end

      context "when scrapbook is not found" do
        before :each do
          allow(Scrapbook).to receive(:find).with(scrapbook.to_param).and_raise(ActiveRecord::RecordNotFound)
          get :show, id: scrapbook.id
        end

        it 'renders the Not Found page' do
          expect(response).to render_template('exceptions/not_found')
        end

        it 'has a 404 status' do
          expect(response.status).to eql(404)
        end
      end
    end
  end
end

