class PcpItemsController < ApplicationController
  include ControllerMethods

  # Note on access permissions: all users may view all items of previously
  # released steps and related public comments; only viewing group may see
  # non-public items.

  initialize_feature FEATURE_ID_PCP_ITEMS, FEATURE_ACCESS_USER + FEATURE_ACCESS_NBP, FEATURE_CONTROL_CUG

  # GET /pcs/:pcp_subject_id/pci
  #
  # show list of all pcp items for the given pcp subject
  #
  # permitted users must have feature access;
  # to see items not yet released, user must be member of the current PCP Group
  # with explicit access permission.

  def index
    get_subject
    parent_breadcrumb( :pcp_subjects, pcp_subjects_path )
    @filter_fields = filter_params
    @pcp_step = @pcp_subject.current_step
    @pcp_group = @pcp_step.acting_group_index
    @pcp_items = @pcp_subject.pcp_items.includes( :pcp_step )
    # restrict view to released items unless current user is in current group
    #@pcp_items = @pcp_items.released( @pcp_subject ) unless user_has_permission?( :to_access )
    @pcp_items = @pcp_items.released unless user_has_permission?( :to_access )
    @pcp_items = @pcp_items.filter( filter_params ).paginate( page: params[ :page ])
  end

  # GET /pci/:id
  #
  # show item and comments

  def show
    get_item
    @pcp_subject = @pcp_item.pcp_subject
    @pcp_step = @pcp_item.pcp_step
    unless user_has_permission?( :to_access )
      render_bad_logic t( 'pcp_items.msg.nop_to_view' )
      return
    end
    unless user_may_view_item? 
      render_bad_logic t( 'pcp_items.msg.nop_not_yet' )
      return
    end
    parent_breadcrumb( :pcp_subject, pcp_subject_path( @pcp_subject ))
    set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_subject ))
    get_item_details
  end

  # GET /pci/:id/next
  #
  # show next item and all comments

  def show_next
    get_item
    @pcp_subject = @pcp_item.pcp_subject
    @pcp_step = @pcp_item.pcp_step
    # try to find next item, check access to remaining item later
    ps = @pcp_item # save original record
    loop do
      pi = @pcp_item.find_next
      if pi.nil? then
        flash.now[ :notice ] = t( 'pcp_items.msg.last_reached' )
        @pcp_item = ps # revert back to original record
        @pcp_step = @pcp_item.pcp_step
      else
        @pcp_item = pi
        @pcp_step = @pcp_item.pcp_step
        next unless user_has_permission?( :to_access )
        next unless user_may_view_item?
      end
      break
    end
    # now check permissions - worst case: original item was already inaccessible!
    unless user_has_permission?( :to_access )
      render_bad_logic t( 'pcp_items.msg.nop_to_view' )
      return
    end
    unless user_may_view_item? 
      render_bad_logic t( 'pcp_items.msg.nop_not_yet' )
      return
    end
    parent_breadcrumb( :pcp_subject, pcp_subject_path( @pcp_subject ))
    set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_subject ))
    set_final_breadcrumb( :show )
    get_item_details
    render :show
  end

  # mark last comment as public; only for owner or deputy

  def update_publish
    get_item
    @pcp_subject = @pcp_item.pcp_subject
    @pcp_step = @pcp_subject.current_step
    if @pcp_step.status_closed?
      render_bad_logic t( 'pcp_items.msg.subj_closed')
      return
    end
    determine_group_map( :to_update )
    unless @pcp_subject.user_is_owner_or_deputy?( current_user, @pcp_group_map )
      render_no_permission
      return
    end
    if @pcp_item.pcp_comments.empty? then
      if @pcp_item.pcp_step == @pcp_step then
        notice_text = 'pcp_items.msg.pub_no_need'
      else
        notice_text = 'pcp_items.msg.pub_no_comment'
      end
    else
      @pcp_comment = @pcp_item.pcp_comments.last
      if @pcp_comment.pcp_step == @pcp_subject.current_step then
        if @pcp_comment.is_public then
          notice_text = 'pcp_items.msg.comment_pub'
        else
          @pcp_comment.make_public
          notice_text = 'pcp_items.msg.publish_ok'
        end
      else
        notice_text = 'pcp_items.msg.pub_comment_no'
      end
    end
    respond_to do |format|
      format.html { redirect_to @pcp_item, notice: t( notice_text )}
    end
  end

  # GET /pci/:pcp_subject_id/pci/new
  #
  # prepare form for new pcp item for the given pcp subject
  # any PCP Participant in commenting group with :to_update permission may
  # create items unless PCP Subject is closed.

  def new
    get_subject
    @pcp_step = @pcp_subject.current_step
    if @pcp_step.status_closed?
      render_bad_logic t( 'pcp_items.msg.subj_closed')
      return
    end
    unless @pcp_step.in_commenting_group?
      render_bad_logic t( 'pcp_items.msg.not_com_grp' )
      return
    end
    unless user_has_permission?( :to_update )
      render_bad_logic t( 'pcp_items.msg.nop_for_new' )
      return
    end
    parent_breadcrumb( :pcp_subject, pcp_subject_path( @pcp_subject ))
    set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_subject ))
    @pcp_item = @pcp_subject.pcp_items.new
    @pcp_item.pcp_step_id = @pcp_step.id
    @pcp_item.set_next_seqno
    @pcp_item.author = current_user.account_info
  end

  # GET /pci/:id/pco/new
  #
  # new PCP Comment for given pcp item; any PCP Participant with :to_update
  # permission may comment on items if (a) PCP Subject is not yet closed;
  # (b) user is in current PCP Group.

  def new_comment
    get_item
    @pcp_subject = @pcp_item.pcp_subject
    @pcp_step = @pcp_subject.current_step
    if @pcp_step.status_closed?
      render_bad_logic t( 'pcp_items.msg.subj_closed' )
      return
    end
    unless user_has_permission?( :to_update )
      render_no_permission
      return
    end
    parent_breadcrumb( :pcp_subject, pcp_subject_path( @pcp_subject ))
    set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_subject ))
    @pcp_comment = PcpComment.new do |c|
      c.pcp_item = @pcp_item
      c.author = current_user.account_info
      c.pcp_step = @pcp_step
      c.assessment = @pcp_item.new_assmt
      c.is_public = false
      c.description = t( 'pcp_items.msg.item_closed' ) if @pcp_item.closed?
    end
    @pcp_comments_show = @pcp_item.pcp_comments
  end

  # GET /pci/:id/edit
  #
  # edit pcp item; any user with :to_update permission for this PCP Subject
  # can make changes to the PCP Item. 

  def edit
    get_item
    @pcp_step = @pcp_item.pcp_step
    if @pcp_step.status_closed?
      render_bad_logic t( 'pcp_items.msg.subj_closed')
      return
    end
    # if there already PCP Comments, redirect to modify last comment
    unless @pcp_item.pcp_comments.empty?
      respond_to do |format|
        format.html { redirect_to edit_pcp_comment_path @pcp_item.pcp_comments.last }
      end
      return
    end
    if @pcp_step.status_closed?
      render_bad_logic t( 'pcp_items.msg.subj_closed' )
      return
    end
     # can only edit PCP Item while it is not yet released
    @pcp_subject = @pcp_item.pcp_subject
    unless @pcp_step == @pcp_subject.current_step
      respond_to do |format|
        format.html { redirect_to @pcp_item, notice: t( 'pcp_items.msg.edit_bad_step' )}
      end
      return
    end
    unless user_has_permission?( :to_update )
      render_no_permission
      return
    end
    parent_breadcrumb( :pcp_subject, pcp_subject_path( @pcp_subject ))
    set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_subject ))
  end

  # edit pcp comment
  #
  # GET /pco/:id/edit

  def edit_comment
    get_comment
    @pcp_item = @pcp_comment.pcp_item
    @pcp_subject = @pcp_item.pcp_subject
    @pcp_step = @pcp_subject.current_step
    if @pcp_step.status_closed?
      render_bad_logic t( 'pcp_items.msg.subj_closed' )
      return
    end
    if @pcp_comment.pcp_step == @pcp_step then
      if user_has_permission?( :to_update ) then
        parent_breadcrumb( :pcp_subject, pcp_subject_path( @pcp_subject ))
        set_breadcrumb_path( pcp_subject_pcp_items_path( @pcp_subject ))
        @pcp_item_show, @pcp_item_edit = @pcp_item, nil
        @pcp_comments_show = @pcp_item.pcp_comments
      else
        render_no_permission
      end
    else
      respond_to do |format|
        format.html { redirect_to @pcp_item, notice: t( 'pcp_items.msg.comment_step' )}
      end
    end
  end    

  # create new pcp item
  #
  # POST /pcs/:pcp_subject_id/pci

  def create
    get_subject
    @pcp_step = @pcp_subject.current_step
    if @pcp_step.status_closed?
      render_bad_logic t( 'pcp_items.msg.subj_closed' )
      return
    end
    if @pcp_step.in_commenting_group? && user_has_permission?( :to_update ) then
      @pcp_item =  @pcp_subject.pcp_items.new( pcp_item_params )
      @pcp_item.transaction do
        @pcp_item.pcp_step_id = @pcp_step.id
        @pcp_item.set_next_seqno
        if @pcp_item.save
          respond_to do |format|
            format.html { redirect_to @pcp_item, notice: t( 'pcp_items.msg.new_ok' )}
          end
        else
          respond_to do |format|
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
    @pcp_step = @pcp_subject.current_step
    if @pcp_step.status_closed?
      render_bad_logic t( 'pcp_items.msg.subj_closed')
      return
    end
    if user_has_permission?( :to_update ) then
      @pcp_comment = @pcp_item.pcp_comments.new( pcp_comment_params )
      @pcp_comment.pcp_step = @pcp_step
      @pcp_comment.assessment = @pcp_item.pub_assmt if @pcp_step.in_presenting_group?
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
    @pcp_step = @pcp_subject.current_step
    if @pcp_step.status_closed?
      render_bad_logic t( 'pcp_items.msg.subj_closed')
      return
    end
    if user_has_permission?( :to_update ) then
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
    @pcp_subject = @pcp_item.pcp_subject
    @pcp_step = @pcp_subject.current_step
    if @pcp_step.status_closed?
      render_bad_logic t( 'pcp_items.msg.subj_closed')
      return
    end
    if user_has_permission?( :to_update ) then
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
    if @pcp_subject.user_is_owner_or_deputy?( current_user, @pcp_item.pcp_step.acting_group_index )
      if @pcp_item.released?
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
    if @pcp_subject.user_is_owner_or_deputy?( current_user, @pcp_comment.pcp_step.acting_group_index )
      if @pcp_comment.published?
        notice = 'pcp_comments.msg.cannot_del'
      else
        @pcp_comment.transction do
          @pcp_comment.destroy
          @pcp_item.update_new_assmt( nil )
        end
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
    @pcp_subject.user_is_owner_or_deputy?( current_user, @pcp_subject.current_step.acting_group_index )
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

    # set what to show:
    # leave @pcp_item_edit on nil if user cannot edit this item
    # leave @pcp_comment_edit on nil if user cannot edit this comment

    def get_item_details
      @pcp_comments_show = @pcp_item.pcp_comments
      @pcp_comment_edit = nil
      @pcp_item_show = @pcp_item
      @pcp_item_edit = nil

      # only if the current user belongs to the acting group, and
      # the last comment - if it exists - belongs to the current step
      # then we can edit it

      if @pcp_step.in_commenting_group? && user_has_permission?( :to_access ) then
        pcp_comment_last = @pcp_comments_show.last
        pcp_subject_step = @pcp_subject.current_step
        if pcp_comment_last.nil? then
          # no last comment
        elsif pcp_comment_last.pcp_step != pcp_subject_step then
          # last comment from previous steps
        elsif PcpSubject.same_group?( pcp_comment_last.pcp_step.acting_group_index, @pcp_group_map )
          # last comment was made by current, acting group
          @pcp_comment_edit = pcp_comment_last
        end

        # only if 
        # (1) the item was created in the current step,
        # (2) subject closed, (this condition does not need to be checked as
        #     this cannot happen: items can only be modified by commenting
        #     group but a closed subject would be with presenting group)
        # (3) item is not yet released (no need to check as condition (1)
        #     would fail if item is released)
        # (4) there is no comment to be edited yet,
        # (5) the current group is acting
        # we could allow to edit the item

        if @pcp_item.pcp_step == pcp_subject_step &&
           @pcp_comments_show.empty? &&
           @pcp_comment_edit.nil? &&
           PcpSubject.same_group?( @pcp_item.pcp_step.acting_group_index, @pcp_group_map )then
          @pcp_item_edit, @pcp_item_show = @pcp_item, nil
        end
      end

    end

    # check if current user is owner, deputy, or member of acting group;
    # save result in @pcp_access to avoid duplicate database access calls.
    # Note: since one action requires only one type of access, it is safe
    # to assume that the result in @pcp_access is valid throughout the action!

    def user_has_permission?( access_type )
      if @pcp_permission.nil? then
        determine_group_map( access_type )
        @pcp_group_act = @pcp_step.acting_group_index
        @pcp_permission = PcpSubject.same_group?( @pcp_group_act, @pcp_group_map )
      end 
      @pcp_permission
    end

    # just a helper 

    def determine_group_map( access_type = :to_access )
      @pcp_group_map ||= @pcp_subject.viewing_group_map( current_user, access_type )
    end

    # checks if a user is permitted to view a PCP Item:
    # the item must be released and public, or we are in 
    # the commenting group (which created the PCP Item)

    def user_may_view_item?
      @pcp_step.released? || @pcp_step.in_commenting_group?
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def pcp_item_params
      params.require( :pcp_item ).permit( :author, :reference, :description, :assessment )
    end

    def pcp_comment_params
      valid_params = [  :author, :description ]
      valid_params.push [ :assessment ] if @pcp_step.in_commenting_group?
      valid_params.push [ :is_public ] if permitted_to_publish?
      params.require( :pcp_comment ).permit( valid_params )
    end

    def filter_params
      params.slice( :ff_seqno, :ff_refs, :ff_desc, :ff_status ).clean_up
    end

    # for testing, I need to be able to reset internal variables

  public

    def reset_4_test
      @pcp_group_map = nil
      @pcp_permission = nil
    end

end
