class A7CodesController < ApplicationController
  initialize_feature FEATURE_ID_A7_CODE, FEATURE_ACCESS_VIEW
  before_action :set_a7_code, only: [ :show, :edit, :update, :destroy ]

  # GET /a7cs

  def index
    @filter_fields = filter_params
    @a7_codes = A7Code.std_order.filter( @filter_fields ).paginate( page: params[ :page ])
    self.feature_help_file = :a_coding_system
  end

  # GET /a7cs/1

  def show
  end

  # GET /a7cs/new

  def new
    @a7_code = A7Code.new
  end

  # GET /a7cs/1/edit

  def edit
  end

  # POST /a7cs

  def create
    @a7_code = A7Code.new( a7_code_params )
    respond_to do |format|
      if @a7_code.save
        format.html { redirect_to @a7_code, notice: I18n.t( 'a_code_modules.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /a7cs/1

  def update
    respond_to do |format|
      if @a7_code.update( a7_code_params )
        format.html { redirect_to @a7_code, notice: I18n.t( 'a_code_modules.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /a7cs/1

  def destroy
    @a7_code.destroy
    respond_to do |format|
      format.html { redirect_to a7_codes_url, notice: I18n.t( 'a_code_modules.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_a7_code
      @a7_code = A7Code.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def a7_code_params
      params.require( :a7_code ).permit( :code, :label, :active, :master, :mapping, :description )
    end

    def filter_params
      params.slice( :as_code, :as_desc ).clean_up
    end

end
