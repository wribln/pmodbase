class PcpItemsController < ApplicationController
  include ControllerMethods

  # Note on access permissions: all users may view all items of previously
  # released steps and related public comments; only viewing group may see
  # non-public items.

  initialize_feature FEATURE_ID_PCP_ITEMS, FEATURE_ACCESS_USER + FEATURE_ACCESS_NDA, FEATURE_CONTROL_CUG

  # show list of all pcp items for the given pcp subject
  #
  # GET /pcs/:pcp_subject_id/pci

  def index
    get_subject
    parent_breadcrumb( :pcp_subjects, pcp_subjects_path )
    @filter_fields = filter_params
    @pcp_step = @pcp_subject.current_steps.first
    @pcp_items = PcpItem.all
    @pcp_items = @pcp_items.released( @pcp_subject ) unless current_user_acting?
    @pcp_items = @pcp_items.filter( filter_params ).paginate( page: params[ :page ])
  end

  # show item and all comments
  #
  # GET /pci/:id

  def show
    get_item
    @pcp_subject = @pcp_item.pcp_subject
    @pcp_step = @pcp_item.pcp_step
    if @pcp_step.released? || current_user_acting? then
      parent_breadcrumb( :pcp_subject, pcp_subject_path( @pcp_subject ))
      set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_subject ))
      get_item_details
    else
      render_no_permission
    end
  end

  # show next item and all comments
  #
  # GET /pci/:id/next

  def show_next
    get_item
    begin
      pi = @pcp_item.find_next
      if pi.nil? then
        flash.now[ :notice ] = t( 'pcp_items.msg.last_reached' )
      else
        @pcp_item = pi
      end
      @pcp_subject = @pcp_item.pcp_subject
      @pcp_step = @pcp_item.pcp_step
    end until @pcp_step.released? || current_user_acting? || pi.nil?
    if @pcp_step.released? || current_user_acting? then
      parent_breadcrumb( :pcp_subject, pcp_subject_path( @pcp_subject ))
      set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_subject ))
      get_item_details
      set_final_breadcrumb( :show )
      render :show
    else
      render_no_permission
    end
  end

  # new pcp item for given pcp subject
  #
  # GET /pci/:pcp_subject_id/pci/new

  def new
    get_subject
    @pcp_step = @pcp_subject.current_steps.first
    if current_user_acting? then
      parent_breadcrumb( :pcp_subject, pcp_subject_path( @pcp_subject ))
      set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_subject ))
      @pcp_item = @pcp_subject.pcp_items.new
      @pcp_item.pcp_step_id = @pcp_step.id
      @pcp_item.set_next_seqno
      @pcp_item.author = current_user.account_info
    else
      render_no_permission
    end
  end

  # new pcp comment for given pcp item
  #
  # GET /pci/:id/pco/new

  def new_comment
    get_item
    @pcp_subject = @pcp_item.pcp_subject
    @pcp_step = @pcp_subject.current_steps.first
    if current_user_acting? then
      parent_breadcrumb( :pcp_subject, pcp_subject_path( @pcp_subject ))
      set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_subject ))
      @pcp_comment = PcpComment.new
      @pcp_comment.pcp_item = @pcp_item
      @pcp_comment.author = current_user.account_info
      @pcp_comment.pcp_step = @pcp_step
      @pcp_comments_show = @pcp_item.pcp_comments
    else
      render_no_permission
    end
  end

  # edit pcp item  
  #
  # GET /pci/:id/edit

  def edit
    get_item
    if @pcp_item.pcp_comments.empty? then
      @pcp_subject = @pcp_item.pcp_subject
      @pcp_step = @pcp_subject.current_steps.first
      if current_user_acting? then
        parent_breadcrumb( :pcp_subject, pcp_subject_path( @pcp_subject ))
        set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_subject ))
      else
        render_no_permission
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_pcp_comment_path }
      end
    end
  end

  # edit pcp comment
  #
  # GET /pco/:id/edit

  def edit_comment
    get_comment
    @pcp_item = @pcp_comment.pcp_item
    @pcp_subject = @pcp_item.pcp_subject
    @pcp_step = @pcp_subject.current_steps.first
    if current_user_acting? then
      parent_breadcrumb( :pcp_subject, pcp_subject_path( @pcp_subject ))
      set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_subject ))
      @pcp_item_show, @pcp_item_edit = @pcp_item, nil
      @pcp_comments_show = @pcp_item.pcp_comments
    else
      render_no_permission
    end
  end    

  # create new pcp item
  #
  # POST /pcs/:pcp_subject_id/pci

  def create
    get_subject
    @pcp_step = @pcp_subject.current_steps.first
    if current_user_acting? then
      @pcp_item =  @pcp_subject.pcp_items.new( pcp_item_params )
      respond_to do |format|
        @pcp_item.transaction do
          @pcp_item.pcp_step_id = @pcp_step.id
          @pcp_item.set_next_seqno
         if @pcp_item.save
            format.html { redirect_to @pcp_item, notice: t( 'pcp_items.msg.new_ok' )}
          else
            format.html { render :new }
          end
        end
      end
    else
      render_no_permission
    end
  end

  # POST /pci/1/pco

  def create_comment
    get_item
    @pcp_subject = @pcp_item.pcp_subject
    @pcp_step = @pcp_subject.current_steps.first
    if current_user_acting? then
      @pcp_comment = @pcp_item.pcp_comments.new( pcp_comment_params )
      @pcp_comment.pcp_step = @pcp_item.pcp_step
      respond_to do |format|
        if @pcp_comment.save
          format.html { redirect_to @pcp_item, notice: t( 'pcp_comments.msg.new_ok' )}
        else
          @pcp_comments_show = @pcp_item.pcp_comments
          format.html { render :new_comment }
        end
      end
    else
      render_no_permission
    end
  end

  # update item with :id
  #
  # PATCH/PUT /pci/1

  def update
    get_item
    @pcp_subject = @pcp_item.pcp_subject
    @pcp_step = @pcp_subject.current_steps.first
    if current_user_acting? then
      respond_to do |format|
        if @pcp_item.update( pcp_item_params )
          format.html { redirect_to @pcp_item, notice: t( 'pcp_items.msg.edit_ok' )}
        else
          format.html { render :edit }
        end
      end
    else
      render_no_permission
    end
  end

  # update comment with :id
  #
  # PATCH/PUT /pco/:id

  def update_comment
    get_comment
    @pcp_item = @pcp_comment.pcp_item
    @pcp_subjects = @pcp_item.pcp_subject
    @pcp_step = @pcp_subject.current_steps.first
    if current_user_acting? then
      respond_to do |format|
        if @pcp_comment.update( pcp_comment_params )
          format.html { redirect_to @pcp_comment.pcp_item, notice: t( 'pcp_comments.msg.edit_ok' )}
        else
          format.html { render :edit_comment }
        end
      end
    else
      render_no_permission
    end
  end

  # destroy item with :id and return to list of items for this subject
  # only creating owner or deputy may do this; also, this item must
  # not be released!
  #
  # DELETE /pci/:id

  def destroy
    get_item
    @pcp_subject = @pcp_item.pcp_subject
    if @pcp_subject.user_is_owner_or_deputy?( current_user.id, @pcp_item.pcp_step.acting_group_index )then
      if @pcp_item.released? then
        notice = 'pcp_items.msg.cannot_del'
      else  
        @pcp_item.destroy
        notice = 'pcp_items.msg.delete_ok'
      end
      respond_to do |format|
        format.html { redirect_to pcp_subject_pcp_items_path( @pcp_subject ), notice: t( notice )}
      end
    else
      render_no_permission
    end
  end

  # destroy comment with :id and return to show item
  # only owner or deputy of step in which this comment
  # was created should be able to do this; also, this
  # comment must not be public and released!
  #
  # DELETE /pco/:id

  def destroy_comment
    get_comment
    @pcp_item = @pcp_comment.pcp_item
    if @pcp_subject.user_is_owner_or_deputy?( current_user.id, @pcp_comment.pcp_step.acting_group_index )then
      if @pcp_comment.published? then
        notice = 'pcp_comments.msg.cannot_del'
      else
        @pcp_comment.destroy
        notice = 'pcp_comments.msg.delete_ok'
      end
      respond_to do |format|
        format.html { redirect_to pcp_item_path( @pcp_item ), notice: t( notice )}
      end
    else
      render_no_permission
    end
  end

  # define a helper_method to see if user is permitted to modify public flag

  def permitted_to_publish?
    @pcp_subject.user_is_owner_or_deputy?( current_user.id, @pcp_subject.current_steps.last.acting_group_index )
  end
  helper_method :permitted_to_publish?

  private

    # Use callbacks to share common setup or constraints between actions

    def get_subject
      @pcp_subject = PcpSubject.find( params[ :pcp_subject_id ])
    end

    def get_item
      @pcp_item = PcpItem.find( params[ :id ])
    end

    def get_comment
      @pcp_comment = PcpComment.find( params[ :id ])
    end

    # set what to show and what could be edited

    def get_item_details
      @pcp_comments_show = @pcp_item.pcp_comments
      @pcp_comment_edit = nil
      @pcp_item_show = @pcp_item
      @pcp_item_edit = nil

      # only if the current user belongs to the acting group, there could be
      # the item or the last comment to be edited

      if current_user_acting? then
        pcp_comment_last = @pcp_comments_show.last
        if pcp_comment_last.nil? then
          # no last comment
        elsif PcpSubject.same_group?( pcp_comment_last.pcp_step.acting_group_index, @pcp_group_map )
          # last comment was made by current, acting group
          @pcp_comment_edit = pcp_comment_last
        end
        if PcpSubject.same_group?( @pcp_item.pcp_step.acting_group_index, @pcp_group_map ) &&
          @pcp_comments_show.empty? && @pcp_comment_edit.nil? then
          @pcp_item_edit, @pcp_item_show = @pcp_item, nil
        end
      end
    end

    # check if current user is owner, deputy, or member of acting group
    # save result in @pcp_acting to avoid duplicate method calls

    def current_user_acting?
      if @pcp_acting.nil? then
        @pcp_group_map = @pcp_subject.viewing_group_map( current_user.id )
        @pcp_group_act = @pcp_step.acting_group_index
        @pcp_acting = PcpSubject.same_group?( @pcp_group_act, @pcp_group_map )
      end
      @pcp_acting
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def pcp_item_params
      params.require( :pcp_item ).permit( :author, :reference, :description, :assessment )
    end

    def pcp_comment_params
      valid_params = [  :author, :description, :assessment ]
      valid_params.push [ :is_public ] if permitted_to_publish?
      params.require( :pcp_comment ).permit( valid_params )
    end

    def filter_params
      params.slice( :ff_seqno, :ff_refs, :ff_desc, :ff_status ).clean_up
    end

end
