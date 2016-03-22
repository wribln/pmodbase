class A6CodesController < ApplicationController
  initialize_feature FEATURE_ID_A6_CODE, FEATURE_ACCESS_VIEW
  before_action :set_a6_code, only: [ :show, :edit, :update, :destroy ]

  # GET /a6cs

  def index
    @filter_fields = filter_params
    @a6_codes = A6Code.std_order.filter( @filter_fields ).paginate( page: params[ :page ])
    self.feature_help_file = :a_coding_system
  end

  # GET /a6cs/1

  def show
  end

  # GET /a6cs/new

  def new
    @a6_code = A6Code.new
  end

  # GET /a6cs/1/edit

  def edit
  end

  # POST /a6cs

  def create
    @a6_code = A6Code.new( a6_code_params )
    respond_to do |format|
      if @a6_code.save
        format.html { redirect_to @a6_code, notice: I18n.t( 'a_code_modules.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /a6cs/1

  def update
    respond_to do |format|
      if @a6_code.update( a6_code_params )
        format.html { redirect_to @a6_code, notice: I18n.t( 'a_code_modules.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /a6cs/1

  def destroy
    @a6_code.destroy
    respond_to do |format|
      format.html { redirect_to a6_codes_url, notice: I18n.t( 'a_code_modules.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_a6_code
      @a6_code = A6Code.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def a6_code_params
      params.require( :a6_code ).permit( :code, :label, :active, :master, :mapping, :desc )
    end

    def filter_params
      params.slice( :as_code, :as_desc ).clean_up
    end

end
