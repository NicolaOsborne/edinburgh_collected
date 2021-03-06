require 'rails_helper'

describe MemoriesController do
  let(:visible_memories) { double('visible_memories') }
  let(:sorted_memories)  { double('sorted_memories') }
  let(:format)           { :html }

  before(:each) do
    allow(Memory).to receive(:publicly_visible).and_return(visible_memories)
    allow(sorted_memories).to receive(:page).and_return(sorted_memories)
    allow(sorted_memories).to receive(:per).and_return(sorted_memories)
  end

  describe 'GET index' do
    before(:each) do
      allow(visible_memories).to receive(:by_last_created).and_return(sorted_memories)
      get :index, format: format
    end

    it 'sets the current memory index path' do
      expect(session[:current_memory_index_path]).to eql(memories_path(format: format))
    end

    it "fetches the publicly visible memories" do
      expect(Memory).to have_received(:publicly_visible)
    end

    it "orders them by most recent first" do
      expect(visible_memories).to have_received(:by_last_created)
    end

    it "paginates the results" do
      expect(sorted_memories).to have_received(:page)
    end

    it "assigns the sorted memories" do
      expect(assigns(:memories)).to eql(sorted_memories)
    end

    context 'when request is for HTML' do
      let(:format) { :html }

      it "is successful" do
        expect(response).to be_success
        expect(response.status).to eql(200)
      end

      it "renders the index page" do
        expect(response).to render_template(:index)
      end
    end

    context 'when request is for JSON' do
      let(:format) { :json }

      it 'is successful' do
        expect(response).to be_success
        expect(response.status).to eql(200)
      end

      it "provides JSON" do
        expect(response.content_type).to eql('application/json')
      end
    end

    context 'when request is for GeoJSON' do
      let(:format) { :geojson }

      it 'is successful' do
        expect(response).to be_success
        expect(response.status).to eql(200)
      end

      it "provides GeoJSON" do
        expect(response.content_type).to eql('text/geojson')
      end
    end
  end

  describe 'GET show' do
    let(:user)   { Fabricate.build(:user) }
    let(:memory) { Fabricate.build(:memory) }

    it 'does not set the current memory index path' do
      expect(session[:current_memory_index_path]).to be_nil
    end

    it "fetches the requested memory" do
      allow(Memory).to receive(:find).and_return(memory)
      get :show, id: '123', format: format
      expect(Memory).to have_received(:find).with('123')
    end

    context "when record is found" do
      let(:visible) { false }

      before :each do
        allow(Memory).to receive(:find).and_return(memory)
        allow(memory).to receive(:publicly_visible?).and_return(visible)
      end

      it "assigns fetched memory" do
        get :show, id: '123', format: format
        expect(assigns(:memory)).to eql(memory)
      end

      context 'and memory is visible' do
        let(:visible) { true }

        before :each do
          get :show, id: '123', format: format
        end

        it_behaves_like 'a found memory'
      end

      context 'and the memory is not visible' do
        let(:visible) { false }

        context 'when there is no current user' do
          before :each do
            get :show, id: '123', format: format
          end

          it_behaves_like 'a not found memory'
        end

        context 'and the current user' do
          before :each do
            allow(controller).to receive(:current_user).and_return(user)
            allow(user).to receive(:can_modify?).and_return(can_modify)
            get :show, id: '123', format: format
          end

          context 'cannot modify the memory' do
            let(:can_modify) { false }

            it_behaves_like 'a not found memory'
          end

          context 'can modify the memory' do
            let(:can_modify) { true }

            it_behaves_like 'a found memory'
          end
        end
      end
    end

    context "when record is not found" do
      before :each do
        allow(Memory).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
        get :show, id: '123', format: format
      end

      it_behaves_like 'a not found memory'
    end
  end
end
