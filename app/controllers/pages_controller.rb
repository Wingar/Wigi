class PagesController < ApplicationController
  before_action :set_page

  # GET /pages/1
  def show
  end

  # GET /pages/new
  def new
  end

  # GET /pages/1/edit
  def edit
  end

  # PATCH/PUT /pages/1
  def update
  end

  # DELETE /pages/1
  def destroy
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
      params[:page]
    end
end
