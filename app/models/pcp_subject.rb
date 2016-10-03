require 'core_ext/string'
class PcpSubject < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include AccountAccess
  include Filterable

  belongs_to :pcp_category, -> { readonly }, inverse_of: :pcp_subjects
  belongs_to :c_group,  -> { readonly }, foreign_key: :c_group_id, class_name: 'Group'
  belongs_to :p_group,  -> { readonly }, foreign_key: :p_group_id, class_name: 'Group'
  belongs_to :c_owner,  -> { readonly }, foreign_key: :c_owner_id, class_name: 'Account'
  belongs_to :p_owner,  -> { readonly }, foreign_key: :p_owner_id, class_name: 'Account'
  belongs_to :c_deputy, -> { readonly }, foreign_key: :c_deputy_id, class_name: 'Account'
  belongs_to :p_deputy, -> { readonly }, foreign_key: :p_deputy_id, class_name: 'Account'
  belongs_to :s_owner,  -> { readonly }, foreign_key: :s_owner_id, class_name: 'Account'
  belongs_to :cfr_record, ->{ readonly }, inverse_of: :pcp_subjects
  has_many   :pcp_steps,    -> { most_recent }, dependent: :destroy, autosave: true,  inverse_of: :pcp_subject
  has_many   :pcp_items,                        dependent: :destroy, validate: false, inverse_of: :pcp_subject
  has_many   :pcp_members,                      dependent: :destroy, validate: false, inverse_of: :pcp_subject
  has_many   :pcp_a_members, -> { where to_access: true }, class_name: 'PcpMember'

  accepts_nested_attributes_for :pcp_steps

  before_validation :set_defaults_from_pcp_category, on: :create
  before_validation :set_defaults_from_pcp_category_group, on: :update
  after_validation :set_title_and_doc_ids

  validates :pcp_category,
    presence: true

  validates :c_group, :p_group,
            :c_owner, :p_owner,
    presence: true, on: :update

  validates :c_deputy,
    presence: true, if: Proc.new{ |me| me.c_deputy_id.present? }

  validates :p_deputy,
    presence: true, if: Proc.new{ |me| me.p_deputy_id.present? }

  validates :s_owner,
    presence: true, if: Proc.new{ |me| me.s_owner_id.present? }

  validates :cfr_record,
    presence: true, if: Proc.new{ |me| me.cfr_record_id.present? }

  validates :title,
    length: { maximum: MAX_LENGTH_OF_TITLE }

  validates :note,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  validates :project_doc_id, :report_doc_id,
    length: { maximum: ProjectDocLog::MAX_LENGTH_OF_DOC_ID }

  # make sure the given account has access for this PCP Subject

  validate{ given_account_has_access( :c_owner_id, :c_group_id, FEATURE_ID_MY_PCP_SUBJECTS )}
  validate{ given_account_has_access( :p_owner_id, :p_group_id, FEATURE_ID_MY_PCP_SUBJECTS )}

  validate :archived_and_status

  set_trimmed :title, :project_doc_id, :report_doc_id

  # all_active is used by controller - make sure it matches an index

  scope :all_active, ->{ where( archived: false ).order( pcp_category_id: :asc, id: :desc )}

  # all permitted are those PCP Subjects where the given account is either
  # owner, deputy, subject owner, or a member of the PCP Group; this is used
  # by the index action in the PcpSubjectsController

  scope :all_permitted, ->( acnt ){ 
    eager_load( :pcp_a_members ).
    where( 'p_owner_id = :param OR c_owner_id = :param OR p_deputy_id = :param OR c_deputy_id = :param OR s_owner_id = :param OR account_id = :param', param: acnt )}

  scope :ff_id,   -> ( id   ){ where id: id }
  scope :ff_titl, -> ( titl ){ where( 'title LIKE :param OR project_doc_id LIKE :param', param: "%#{ titl }%" )}
  scope :ff_igrp, -> ( igrp ){ where( 'p_group_id = :param OR c_group_id = :param', param: igrp )}
  scope :ff_cgrp, -> ( cgrp ){ where( c_group_id: cgrp )}
  scope :ff_pgrp, -> ( pgrp ){ where( p_group_id: pgrp )}
  scope :ff_note, -> ( note ){ where( 'note LIKE ?', "%#{ note }%" )}

  # make sure that archived status can only be set if subject status is closed

  def archived_and_status
    if archived then
      errors.add( :archived, I18n.t( 'pcp_subjects.msg.bad_status' )) \
        unless current_steps[ 0 ].status_closed?
    end
  end

  # retrieve the current and previous pcp_step

  def current_steps
    pcp_steps.most_recent.first(2)
  end

  def current_step
    pcp_steps.most_recent.first
  end

  def previous_step
    pcp_steps.most_recent.second
  end

  # providing the acting_group_index as parameter is more efficient than
  # referring to current_step.acting_group_index as the current_step is mostly
  # likely known/retrieved when this method is called

  def get_acting_group( agi )
    Group.find( agi == 0 ? p_group_id : c_group_id )
  end

  # determine from the account of the current user whether she belongs to the acting
  # group, i.e. either to the presenting group or to the commenting group or even to
  # another group; this controls what information the user is able to view; as we can
  # have the same project group for both presenting and commenting group, I will use
  # a bit map for this purpose
  # 0 - other group
  # 1 - presenting group
  # 2 - commenting group
  # 3 - both presenting and commenting group

  def viewing_group_map( user, access = :to_access )
    return 0 if user.nil?
    r = 0
    r =     1 if ( user.id == p_owner_id  )||
                 ( user.id == p_deputy_id )||
                 ( user.id == s_owner_id  )||
                pcp_members.presenting_member( user.id ).first.try( access )
    r = r | 2 if ( user.id == c_owner_id  )||
                 ( user.id == c_deputy_id )||
                pcp_members.commenting_member( user.id ).first.try( access )
    return r
  end

  # check if acting_group (0 or 1) is same as viewing group ...

  def self.same_group?( acting, viewing_group_map )
    ( acting + 1 )&( viewing_group_map ) != 0
  end

  # if an unsigned integer was given as doc id, retrieve complete doc id and
  # title to be used

  def set_title_and_doc_ids
    if report_doc_id && report_doc_id.is_n? then
      doc = ProjectDocLog.get_title_and_doc_id( report_doc_id.to_i )
      unless doc.nil? then
        write_attribute( :report_doc_id, doc[ 1 ])
      end
    end
    if project_doc_id && project_doc_id.is_n? then
      doc = ProjectDocLog.get_title_and_doc_id( project_doc_id.to_i )
    elsif cfr_record_id && project_doc_id.nil? then
      doc = CfrRecord.get_title_and_doc_id( cfr_record_id )
    else
      doc = nil
    end
    unless doc.nil? then
      write_attribute( :title, doc[ 0 ])
      write_attribute( :project_doc_id, doc[ 1 ])
    end
  end 

  # access control helper: ags is the acting_group_switch

  def user_is_owner_or_deputy?( user, ags )
    return false if user.nil?
    if ags == 0
      ( user.id == p_owner_id )||( user.id == p_deputy_id )
    else
      ( user.id == c_owner_id )||( user.id == c_deputy_id )
    end
  end

  def user_is_creator?( user )
    return false if user.nil?
    s_owner_id == user.id
  end

  # user must have access to group of associated PCP Category in order
  # to create PCP Subjects (possible only in PcpSubjectsController) or
  # if he is the deputy of the presenting group in the selected PCP Category

  def permitted_to_create?( account, feature = FEATURE_ID_MY_PCP_SUBJECTS )
    return false if pcp_category_id.nil?
    pcp_category.p_deputy_id == account.id || 
      account.permission_to_access( feature, :to_create, pcp_category.p_group_id )
  end

  # general permission to access PCP Subjects in PcpAllSubjectsController

  def permitted_to_access?( account, feature = FEATURE_ID_MY_PCP_SUBJECTS, action = :to_read )
    pg = account.permitted_groups( feature, action )
    case pg
    when nil
      false
    when ''
      true
    else # ( pg & [ p_group_id, c_group_id ]).empty?
      pg.include?( p_group_id ) || pg.include?( c_group_id )
    end
  end

  # prepare condition to restrict access to permitted groups for this user
  # this is patterned after Group.permitted_groups but considers here two
  # attributes ... to be used in queries

  def self.permitted_groups( account, feature, action )
    pg = account.permitted_groups( feature, action )
    case pg
    when nil
      none
    when ''
      all
    else
      where( 'p_group_id IN ( :param ) OR c_group_id IN ( :param )', param: pg )
    end      
  end

  # this returns a nice title for the subject, for example to be used in reports
  # or as header for the related PCP Items (Note: this is NOT related to the
  # :subject_title in the PCP Steps records!)

  def subject_title
    self.title || self.project_doc_id || self.to_id
  end

  # return array with of counts per PCP Item assessment

  def get_item_stats
    h = pcp_items.group( :new_assmt ).count
    a = Array.new( PcpItem::ASSESSMENT_LABELS.count, 0 )
    h.each {|k,v| a[ k ] = v }
    return a
  end

  # use this method to determine whether this PCP Subject is valid;
  # this contains additional integrity checks not covered in model
  # validations

  def valid_subject?
    # each PCP Subject should have at least one step
    return 1 if pcp_steps.count == 0
    # no PCP Items should be assigned in PCP Step 0
    return 2 if pcp_steps.most_recent.last.pcp_items.count > 0
    # subject status must be 0 in steps 0 and 1
    if pcp_steps.count == 1 then
      return 3 if current_step.subject_status != 0
    elsif pcp_steps.count == 2 then
      return 4 if current_step.subject_status != 0
    end
    return 0
  end

  protected
    
    # when creating a new PCP Subject, we should take the default values from the
    # PCP Category; the creator of the PCP Subject should become the new owner
    # of the PCP Subject unless it is already defined as deputy.

    def set_defaults_from_pcp_category
      oc = self.pcp_category
      if oc
        set_nil_default( :c_group_id, oc.c_group_id )
        set_nil_default( :p_group_id, oc.p_group_id )
        set_nil_default( :c_owner_id, oc.c_owner_id )
        set_nil_default( :p_owner_id, oc.p_owner_id )
        set_nil_default( :c_deputy_id, oc.c_deputy_id )
        set_nil_default( :p_deputy_id, oc.p_deputy_id )
      end
    end

    # when during an update the group is left blank, the original data from the
    # PCP Category should be used for any non-existing attributes:

    def set_defaults_from_pcp_category_group
      oc = self.pcp_category
      if oc 
        if self.p_group_id.blank?
          set_nil_default( :p_group_id, oc.p_group_id )
          set_nil_default( :p_owner_id, oc.p_owner_id )
          set_nil_default( :p_deputy_id, oc.p_deputy_id )
        end
        if self.c_group_id.blank?
          set_nil_default( :c_group_id, oc.c_group_id )
          set_nil_default( :c_owner_id, oc.c_owner_id )
          set_nil_default( :c_deputy_id, oc.c_deputy_id )
        end
      end
    end          

end
