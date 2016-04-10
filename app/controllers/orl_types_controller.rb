class OrlTypesController < ApplicationController
  before_action :set_orl_type, only: [:show, :edit, :update, :destroy]

  initialize_feature FEATURE_ID_ORL_TYPES, FEATURE_ACCESS_SOME, FEATURE_CONTROL_CUG

  # GET /otp

  def index
    @orl_types = OrlType.all
  end

  # GET /otp/1

  def show
  end

  # GET /otp/new

  def new
    @orl_type = OrlType.new
    set_selections( :to_create )
  end

  # GET /otp/1/edit

  def edit
    set_selections( :to_update )
  end

  # POST /otp

  def create
    @orl_type = OrlType.new( orl_type_params )
    return unless has_group_access?( @orl_type )
    respond_to do |format|
      if @orl_type.save
        format.html { redirect_to @orl_type, notice: I18n.t( 'orl_types.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /otp/1

  def update
    respond_to do |format|
      if @orl_type.update(orl_type_params)
        format.html { redirect_to @orl_type, notice: I18n.t( 'orl_types.msg.edit_ok' )}
      else
        set_selections( :to_create )
        format.html { render :edit }
      end
    end
  end

  # DELETE /otp/1

  def destroy
    @orl_type.destroy
    respond_to do |format|
      format.html { redirect_to orl_types_url, notice: I18n.t( 'orl_types.msg.delete_ok' )}
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_orl_type
      @orl_type = OrlType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def orl_type_params
      params.require( :orl_type ).permit( :o_group_id, :r_group_id, :label )
    end

    def set_selections( action )
      pg = current_user.permitted_groups( FEATURE_ID_ORL_TYPES, action, :id )
      @r_group_selection = Group.active_only.participants_only.permitted_groups( pg ).all.collect{ |g| [ g.code_and_label, g.id ]}
    end

end
