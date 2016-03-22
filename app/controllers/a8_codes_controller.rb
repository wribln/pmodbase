class A8CodesController < ApplicationController
  initialize_feature FEATURE_ID_A8_CODE, FEATURE_ACCESS_VIEW
  before_action :set_a8_code, only: [ :show, :edit, :update, :destroy ]

  # GET /a8cs

  def index
    @filter_fields = filter_params
    @a8_codes = A8Code.std_order.filter( @filter_fields ).paginate( page: params[ :page ])
    self.feature_help_file = :a_coding_system
  end

  # GET /a8cs/1

  def show
  end

  # GET /a8cs/new

  def new
    @a8_code = A8Code.new
  end

  # GET /a8cs/1/edit

  def edit
  end

  # POST /a8cs

  def create
    @a8_code = A8Code.new( a8_code_params )
    respond_to do |format|
      if @a8_code.save
        format.html { redirect_to @a8_code, notice: I18n.t( 'a_code_modules.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /a8cs/1

  def update
    respond_to do |format|
      if @a8_code.update( a8_code_params )
        format.html { redirect_to @a8_code, notice: I18n.t( 'a_code_modules.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /a8cs/1

  def destroy
    @a8_code.destroy
    respond_to do |format|
      format.html { redirect_to a8_codes_url, notice: I18n.t( 'a_code_modules.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_a8_code
      @a8_code = A8Code.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def a8_code_params
      params.require( :a8_code ).permit( :code, :label, :active, :master, :mapping )
    end

    def filter_params
      params.slice( :as_code, :as_desc ).clean_up
    end

end
