class Users::ScrapbooksController < ApplicationController
  before_action :store_scrapbook_index_path, only: :index

  def index
    @requested_user = User.find(params[:user_id])

    redirect_to my_scrapbooks_path and return if @requested_user == current_user
    raise ActiveRecord::RecordNotFound unless @requested_user.publicly_visible?

    scrapbooks = @requested_user.scrapbooks.publicly_visible.by_last_created
    memory_fetcher = ApprovedScrapbookMemoryFetcher.new(scrapbooks)
    @presenter = ScrapbookIndexPresenter.new(scrapbooks, memory_fetcher, params[:page])
  end
end
