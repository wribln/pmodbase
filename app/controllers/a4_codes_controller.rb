class A4CodesController < ApplicationController
  initialize_feature FEATURE_ID_A4_CODE, FEATURE_ACCESS_VIEW
  before_action :set_a4_code, only: [ :show, :edit, :update, :destroy ]

  # GET /a4cs

  def index
    @filter_fields = filter_params
    @a4_codes = A4Code.std_order.filter( @filter_fields ).paginate( page: params[ :page ])
    self.feature_help_file = :a_coding_system
  end

  # GET /a4cs/1

  def show
  end

  # GET /a4cs/new

  def new
    @a4_code = A4Code.new
  end

  # GET /a4cs/1/edit

  def edit
  end

  # POST /a4cs

  def create
    @a4_code = A4Code.new( a4_code_params )
    respond_to do |format|
      if @a4_code.save
        format.html { redirect_to @a4_code, notice: I18n.t( 'a_code_modules.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /a4cs/1

  def update
    respond_to do |format|
      if @a4_code.update( a4_code_params )
        format.html { redirect_to @a4_code, notice: I18n.t( 'a_code_modules.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /a4cs/1

  def destroy
    @a4_code.destroy
    respond_to do |format|
      format.html { redirect_to a4_codes_url, notice: I18n.t( 'a_code_modules.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_a4_code
      @a4_code = A4Code.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def a4_code_params
      params.require( :a4_code ).permit( :code, :label, :active, :master, :mapping )
    end

    def filter_params
      params.slice( :as_code, :as_desc ).clean_up
    end

end
