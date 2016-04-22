class A5CodesController < ApplicationController
  initialize_feature FEATURE_ID_A5_CODE, FEATURE_ACCESS_VIEW
  before_action :set_a5_code, only: [ :show, :edit, :update, :destroy ]

  # GET /a5cs

  def index
    @filter_fields = filter_params
    @a5_codes = A5Code.std_order.filter( @filter_fields ).paginate( page: params[ :page ])
    self.feature_help_file = :a_coding_system
  end

  # GET /a5cs/1

  def show
  end

  # GET /a5cs/new

  def new
    @a5_code = A5Code.new
  end

  # GET /a5cs/1/edit

  def edit
  end

  # POST /a5cs

  def create
    @a5_code = A5Code.new( a5_code_params )
    respond_to do |format|
      if @a5_code.save
        format.html { redirect_to @a5_code, notice: I18n.t( 'a_code_modules.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /a5cs/1

  def update
    respond_to do |format|
      if @a5_code.update( a5_code_params )
        format.html { redirect_to @a5_code, notice: I18n.t( 'a_code_modules.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /a5cs/1

  def destroy
    @a5_code.destroy
    respond_to do |format|
      format.html { redirect_to a5_codes_url, notice: I18n.t( 'a_code_modules.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_a5_code
      @a5_code = A5Code.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def a5_code_params
      params.require( :a5_code ).permit( :code, :label, :active, :master, :mapping, :description )
    end

    def filter_params
      params.slice( :as_code, :as_desc ).clean_up
    end

end
