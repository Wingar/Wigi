class PagesController < ApplicationController
  before_action :set_page, :only => [:show, :edit, :update, :destroy]

  # GET /pages
  def index
    @pages = all_pages
  end

  # GET /pages/1
  def show
  end

  # GET /pages/new
  def new
  end

  # POST /pages
  def create
    new_page(params[:title], params[:page])
    redirect_to "/pages/#{params[:title]}"
  end

  # GET /pages/1/edit
  def edit
  end

  # PATCH/PUT /pages/1
  def update
    update_file(@title, params[:page])
    redirect_to "/pages/#{@title}"
  end

  # POST /pages/1/delete
  def destroy
    delete_page(@title)
    redirect_to "/pages"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      page = find_page(params[:id])
      @title = page[0]
      @contents = find_file(page[1])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params[:title, :page]
    end
end
