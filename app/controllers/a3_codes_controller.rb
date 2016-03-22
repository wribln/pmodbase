class A3CodesController < ApplicationController
  initialize_feature FEATURE_ID_A3_CODE, FEATURE_ACCESS_VIEW
  before_action :set_a3_code, only: [ :show, :edit, :update, :destroy ]

  # GET /a3cs

  def index
    @filter_fields = filter_params
    @a3_codes = A3Code.std_order.filter( @filter_fields ).paginate( page: params[ :page ])
    self.feature_help_file = :a_coding_system
  end

  # GET /a3cs/1

  def show
  end

  # GET /a3cs/new

  def new
    @a3_code = A3Code.new
  end

  # GET /a3cs/1/edit

  def edit
  end

  # POST /a3cs

  def create
    @a3_code = A3Code.new( a3_code_params )
    respond_to do |format|
      if @a3_code.save
        format.html { redirect_to @a3_code, notice: I18n.t( 'a_code_modules.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /a3cs/1

  def update
    respond_to do |format|
      if @a3_code.update( a3_code_params )
        format.html { redirect_to @a3_code, notice: I18n.t( 'a_code_modules.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /a3cs/1

  def destroy
    @a3_code.destroy
    respond_to do |format|
      format.html { redirect_to a3_codes_url, notice: I18n.t( 'a_code_modules.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_a3_code
      @a3_code = A3Code.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def a3_code_params
      params.require( :a3_code ).permit( :code, :label, :active, :master, :mapping, :desc )
    end

    def filter_params
      params.slice( :as_code, :as_desc ).clean_up
    end

end
