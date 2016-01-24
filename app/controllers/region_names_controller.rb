class RegionNamesController < ApplicationController
  initialize_feature FEATURE_ID_REGION_NAMES, FEATURE_ACCESS_SOME
  before_action :set_region_name,  only: [ :show, :edit, :update, :destroy ]
  before_action :set_region_names, only: [ :index ]
  before_action :set_selections,   only: [ :index, :edit, :new, :create, :update ]

  # GET /region_names

  def index
    @filter_fields = filter_params
  end

  # GET /region_names/1

  def show
  end

  # GET /region_names/new

  def new
    @region_name = RegionName.new
  end

  # GET /region_names/1/edit

  def edit
  end

  # POST /region_names

  def create
    @region_name = RegionName.new( region_name_params)
    respond_to do |format|
      if @region_name.save
        format.html { redirect_to @region_name, notice: t( 'region_names.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /region_names/1

  def update
    respond_to do |format|
      if @region_name.update( region_name_params )
        format.html { redirect_to @region_name, notice: t( 'region_names.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /region_names/1

  def destroy
    @region_name.destroy
    respond_to do |format|
      format.html { redirect_to region_names_url, notice: t( 'region_names.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_region_name
      @region_name = RegionName.includes( :country_name ).find( params[ :id ])
    end

    def set_region_names
      @region_names = RegionName.includes( :country_name ).filter( filter_params ).paginate( page: params[ :page ])
    end

    def set_selections
      @country_names = CountryName.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def region_name_params
      params.require( :region_name ).permit( :country_name_id, :code, :label )
    end

    def filter_params
      params.slice( :ff_id, :ff_country, :ff_code, :ff_label ).clean_up
    end
    
end
