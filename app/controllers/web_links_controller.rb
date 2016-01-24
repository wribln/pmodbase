class WebLinksController < ApplicationController
  initialize_feature FEATURE_ID_WEB_LINKS, FEATURE_ACCESS_INDEX
  before_action :set_web_link, only: [:show, :edit, :update, :destroy]

  # GET /wlks

  def index
    @web_links = WebLink.all
  end

  # GET /wlks/1

  def show
  end

  # GET /wlks/new

  def new
    @web_link = WebLink.new
  end

  # GET /wlks/1/edit

  def edit
  end

  # POST /wlks

  def create
    @web_link = WebLink.new( web_link_params )
    respond_to do |format|
      if @web_link.save
        format.html { redirect_to @web_link, notice: t( 'web_links.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /wlks/1

  def update
    respond_to do |format|
      if @web_link.update( web_link_params )
        format.html { redirect_to @web_link, notice: t( 'web_links.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /wlks/1

  def destroy
    @web_link.destroy
    respond_to do |format|
      format.html { redirect_to web_links_url, notice: t( 'web_links.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_web_link
      @web_link = WebLink.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def web_link_params
      params.require( :web_link ).permit( :label, :hyperlink, :seqno )
    end
end
