class CountryNamesController < ApplicationController
  initialize_feature FEATURE_ID_COUNTRY_NAMES, FEATURE_ACCESS_VIEW
  before_action :set_country_name,  only: [ :show, :edit, :update, :destroy ]
  before_action :set_country_names, only: [ :index ]

  # GET /country_names

  def index
    @filter_fields = filter_params
  end

  # GET /country_names/1

  def show
  end

  # GET /country_names/new
  
  def new
    @country_name = CountryName.new
  end

  # GET /country_names/1/edit

  def edit
  end

  # POST /country_names

  def create
    @country_name = CountryName.new( country_name_params )
    respond_to do |format|
      if @country_name.save
        format.html { redirect_to @country_name, notice: t( 'country_names.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /country_names/1

  def update
    respond_to do |format|
      if @country_name.update( country_name_params )
        format.html { redirect_to @country_name, notice: t( 'country_names.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /country_names/1

  def destroy
    @country_name.destroy
    respond_to do |format|
      format.html { redirect_to country_names_url, notice: t( 'country_names.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_country_name
      @country_name = CountryName.find( params[:id] )
    end

    def set_country_names
      @country_names = CountryName.filter( filter_params ).paginate( page: params[ :page ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def country_name_params
      params.require( :country_name ).permit( :id, :code, :label )
    end

    def filter_params
      params.slice( :ff_code, :ff_label ).clean_up
    end
end
