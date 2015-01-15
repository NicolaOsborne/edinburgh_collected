require 'rails_helper'

describe Search::ScrapbooksController do
  let(:format)              { :html }

  describe 'GET index' do
    context 'when no query is given' do
      before :each do
        get :index, format: format, query: nil
      end

      it 'stores the scrapbook index path with no query' do
        expect(session[:current_scrapbook_index_path]).to eql(search_scrapbooks_path(format: format))
      end

      it "redirects to the browse scrapbooks page" do
        expect(response).to redirect_to(scrapbooks_path)
      end
    end

    context 'when a blank query is given' do
      before :each do
        get :index, format: format, query: ''
      end

      it 'stores the scrapbook index path with an empty query' do
        expect(session[:current_scrapbook_index_path]).to eql(search_scrapbooks_path(format: format, query: ''))
      end

      it "redirects to the browse scrapbooks page" do
        expect(response).to redirect_to(scrapbooks_path)
      end
    end

    context 'when a query is given' do
      let(:query)   { "test search" }
      let(:results) { double('results') }

      before(:each) do
        allow(SearchResults).to receive(:new).and_return(results)
      end

      context 'when no page number is given' do
        before :each do
          get :index, format: format, query: query
        end

        it 'stores the scrapbook index path with the given query' do
          expect(session[:current_scrapbook_index_path]).to eql(search_scrapbooks_path(format: format, query: query))
        end

        it 'generates a memory search results presenter for the given query' do
          expect(SearchResults).to have_received(:new).with('scrapbooks', query, nil)
        end

        it "assigns the returned results" do
          expect(assigns(:results)).to eql(results)
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
      end

      context 'when a page number is given' do
        let(:page) { '2' }

        before :each do
          get :index, format: format, query: query, page: page
        end

        it 'stores the scrapbook index path with the given query and page' do
          expect(session[:current_scrapbook_index_path]).to eql(search_scrapbooks_path(format: format, query: query, page: page))
        end

        it 'generates a memory search results presenter for the given query and page' do
          expect(SearchResults).to have_received(:new).with('scrapbooks', query, page)
        end

        it "assigns the returned results" do
          expect(assigns(:results)).to eql(results)
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
      end
    end
  end
end

