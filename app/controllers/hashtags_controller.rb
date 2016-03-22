class HashtagsController < ApplicationController
  include ControllerMethods
  initialize_feature FEATURE_ID_HASHTAGS, FEATURE_ACCESS_VIEW
  before_action :set_hashtag, only: [:show, :edit, :update, :destroy]
  before_action :set_permitted_features, only: [ :edit, :update, :new, :create ]

  # GET /htgs

  def index
    @filter_fields = filter_params
    @all_features = Feature.all_by_label # filtering is allowed for all
    @hashtags = Hashtag.filter( @filter_fields ).paginate( page: params[ :page ])
  end

  # GET /htgs/1

  def show
  end

  # GET /htgs/new

  def new
    @hashtag = Hashtag.new
  end

  # GET /htgs/1/edit

  def edit
  end

  # POST /htgs

  def create
    @hashtag = Hashtag.new( hashtag_params )
    if permission_to_modify then
      respond_to do |format|
        if @hashtag.save
          format.html { redirect_to @hashtag, notice: I18n.t( 'hashtags.msg.new_ok' )}
        else
          format.html { render :new }
        end
      end
    else
      render_no_permission
    end
  end

  # PATCH/PUT /htgs/1

  def update
    @hashtag.assign_attributes( hashtag_params )
    if permission_to_modify then
      respond_to do |format|
        if @hashtag.save
          format.html { redirect_to @hashtag, notice: I18n.t( 'hashtags.msg.edit_ok' )}
        else
          format.html { render :edit }
        end
      end
    else
      render_no_permission
    end
  end

  # DELETE /htgs/1

  def destroy
    @hashtag.destroy
    respond_to do |format|
      format.html { redirect_to hashtags_url, notice: I18n.t( 'hashtags.msg.delete_ok' )}
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.

    def set_hashtag
      @hashtag = Hashtag.find( params[ :id ])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def hashtag_params
      params.require( :hashtag ).permit( :code, :label, :feature_id, :seqno )
    end

    def filter_params
      params.slice( :ff_code, :ff_label, :ff_feature ).clean_up
    end

    # set permitted features to all if access level = 2
    # or to those where use has write access to (access level 1)

    def set_permitted_features
      pf = current_user.permission_to_access( feature_identifier, :to_update ) == 2 ? '' : current_user.permitted_features
      @permitted_features = Feature.permitted_features( pf ).order( label: :asc ).collect{ |f| [ f.label, f.id ]}
    end

    # this method checks if the current user is permitted to create or modify

    def permission_to_modify
      ptm = current_user.permission_to_access( @hashtag.feature_id, :to_update )
      ( ptm && ptm > 0 ) || ( current_user.permission_to_access( feature_identifier, :to_update ) == 2 )
    end

end
