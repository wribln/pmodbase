class A2CodesController < ApplicationController
  initialize_feature FEATURE_ID_A2_CODE, FEATURE_ACCESS_VIEW
  before_action :set_a2_code, only: [ :show, :edit, :update, :destroy ]

  # GET /a2cs

  def index
    @filter_fields = filter_params
    @a2_codes = A2Code.std_order.filter( @filter_fields ).paginate( page: params[ :page ])
    self.feature_help_file = :a_coding_system
  end

  # GET /a2cs/1

  def show
  end

  # GET /a2cs/new

  def new
    @a2_code = A2Code.new
  end

  # GET /a2cs/1/edit

  def edit
  end

  # POST /a2cs

  def create
    @a2_code = A2Code.new( a2_code_params )
    respond_to do |format|
      if @a2_code.save
        format.html { redirect_to @a2_code, notice: I18n.t( 'a_code_modules.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /a2cs/1

  def update
    respond_to do |format|
      if @a2_code.update( a2_code_params )
        format.html { redirect_to @a2_code, notice: I18n.t( 'a_code_modules.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /a2cs/1

  def destroy
    @a2_code.destroy
    respond_to do |format|
      format.html { redirect_to a2_codes_url, notice: I18n.t( 'a_code_modules.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_a2_code
      @a2_code = A2Code.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def a2_code_params
      params.require( :a2_code ).permit( :code, :label, :active, :master, :mapping )
    end

    def filter_params
      params.slice( :as_code, :as_desc ).clean_up
    end

end
