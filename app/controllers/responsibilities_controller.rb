class ResponsibilitiesController < ApplicationController
  initialize_feature FEATURE_ID_RESPONSIBILITIES, FEATURE_ACCESS_SOME, FEATURE_CONTROL_GRP
  before_action :set_responsibility,   only: [ :show, :edit, :update, :destroy ]
  before_action :set_responsibilities, only: [ :index ]

  # GET /responsibilities

  def index
  end

  # GET /responsibilities/1

  def show
  end

  # GET /responsibilities/new

  def new
    @responsibility = Responsibility.new
    set_selections( :to_create )
  end

  # GET /responsibilities/1/edit

  def edit
    set_selections( :to_update )
  end

  # POST /responsibilities

  def create
    @responsibility = Responsibility.new( responsibility_params )
    return unless has_group_access?( @responsibility )
    respond_to do |format|
      if @responsibility.save
        format.html { redirect_to @responsibility, notice: t('responsibilities.msg.new_ok' )}
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /responsibilities/1

  def update
    respond_to do |format|
      if @responsibility.update( responsibility_params )
        format.html { redirect_to @responsibility, notice: t('responsibilities.msg.edit_ok' )}
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /responsibilities/1

  def destroy
    @responsibility.destroy
    respond_to do |format|
      format.html { redirect_to responsibilities_url, notice: t( 'responsibilities.msg.delete_ok' )}
    end
  end

  private
  
    # Use callbacks to share common setup or constraints between actions.

    def set_responsibility
      @responsibility = Responsibility.find( params[ :id ])
      return unless has_group_access?( @responsibility )
    end

    def set_responsibilities
      @responsibilities = Responsibility.includes( :group ).order( :group_id, :seqno )
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def responsibility_params
      params.require( :responsibility ).permit( :description, :seqno, :group_id, :person_id )
    end

    # Groups to select from are those for which the current user has access to

    def set_selections( action )
      pg = current_user.permitted_groups( FEATURE_ID_RESPONSIBILITIES, action, :id )
      @group_selection = Group.permitted_groups( pg ).all.collect{ |g| [ g.code, g.id ]}
    end

end
