class A1CodesController < ApplicationController
  initialize_feature FEATURE_ID_A1_CODE, FEATURE_ACCESS_VIEW
  before_action :set_a1_code, only: [ :show, :edit, :update, :destroy ]

  # GET /a1cs

  def index
    @filter_fields = filter_params
    @a1_codes = A1Code.std_order.filter( @filter_fields ).paginate( page: params[ :page ])
    self.feature_help_file = :a_coding_system
  end

  # GET /a1cs/1

  def show
  end

  # GET /a1cs/new

  def new
    @a1_code = A1Code.new
  end

  # GET /a1cs/1/edit

  def edit
  end

  # POST /a1cs

  def create
    @a1_code = A1Code.new( a1_code_params )
    respond_to do |format|
      if @a1_code.save
        format.html { redirect_to @a1_code, notice: I18n.t( 'a_code_modules.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /a1cs/1

  def update
    respond_to do |format|
      if @a1_code.update( a1_code_params )
        format.html { redirect_to @a1_code, notice: I18n.t( 'a_code_modules.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /a1cs/1

  def destroy
    @a1_code.destroy
    respond_to do |format|
      format.html { redirect_to a1_codes_url, notice: I18n.t( 'a_code_modules.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_a1_code
      @a1_code = A1Code.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def a1_code_params
      params.require( :a1_code ).permit( :code, :label, :active, :master, :mapping )
    end

    def filter_params
      params.slice( :as_code, :as_desc ).clean_up
    end

end
