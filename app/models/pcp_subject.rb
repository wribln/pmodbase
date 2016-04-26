class PcpSubject < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include PcpSubjectAccess

  belongs_to :pcp_category, -> { readonly }, inverse_of: :pcp_subjects
  belongs_to :c_group,  -> { readonly }, foreign_key: :c_group_id, class_name: Group
  belongs_to :p_group,  -> { readonly }, foreign_key: :p_group_id, class_name: Group
  belongs_to :c_owner,  -> { readonly }, foreign_key: :c_owner_id, class_name: Account
  belongs_to :p_owner,  -> { readonly }, foreign_key: :p_owner_id, class_name: Account
  belongs_to :c_deputy, -> { readonly }, foreign_key: :c_deputy_id, class_name: Account
  belongs_to :p_deputy, -> { readonly }, foreign_key: :p_deputy_id, class_name: Account
  has_many   :pcp_steps,    -> { most_recent }, dependent: :destroy, validate: false, inverse_of: :pcp_subject
  accepts_nested_attributes_for :pcp_steps

  before_validation :set_defaults_from_pcp_categories, on: :create

  validates :pcp_category_id,
    presence: true

  validates :c_group_id, :c_owner_id, :p_group_id, :p_owner_id,
    presence: true,
    on: :update

  validates :title,
    length: { maximum: MAX_LENGTH_OF_TITLE }

  validates :note,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  validates :project_doc_id, :report_doc_id,
    length: { maximum: MAX_LENGTH_OF_DOC_ID }

  validate :pcp_category_exists

  validate { given_account_has_access( :c_owner_id,  :c_group_id )}
  validate { given_account_has_access( :c_deputy_id, :c_group_id )}
  validate { given_account_has_access( :p_owner_id,  :p_group_id )}
  validate { given_account_has_access( :p_deputy_id, :p_group_id )}

  validate :archived_and_status

  # all_active is used by controller - make sure it matches an index

  scope :all_active, ->{ where( archived: false ).order( pcp_category_id: :asc, id: :desc )}

  # make sure that archived status can only be set if subject status is closed

  def archived_and_status
    if archived then
      errors.add( :archived, I18n.t( 'pcp_subjects.msg.bad_status' )) \
        unless current_step.status_closed?
    end
  end

  # ensure that the selected/given pcp_category really exists

  def pcp_category_exists
    unless pcp_category_id.nil? then
      errors.add( :pcp_category_id, I18n.t( 'pcp_subjects.msg.bad_category' )) \
        unless PcpCategory.exists?( pcp_category_id )
    end
  end

  # retrieve the current pcp_step

  def current_step
    pcp_steps.most_recent.first
  end

  # providing the acting_group_index as parameter is more efficient than
  # referring to current_step.acting_group_index as the current_step is mostly
  # likely known/retrieved when this method is called

  def get_acting_group( ags )
    Group.find( ags == 0 ? c_group_id : p_group_id )
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

  def viewing_group_index( id )
    r = 0
    r =     1 if ( id == p_owner_id )||( id == p_deputy_id ) 
    r = r | 2 if ( id == c_owner_id )||( id == c_deputy_id )
    return r
  end

  # check if acting_group (0 or 1) is same as viewing group ...

  def self.same_group?( acting, viewing )
    ( acting + 1 )&( viewing ) != 0
  end

  # fix assignments

  def title=( text )
    write_attribute( :title, AppHelper.clean_up( text, MAX_LENGTH_OF_DESCRIPTION ))
  end

  def project_doc_id=( text )
    write_attribute( :project_doc_id, AppHelper.clean_up( text, MAX_LENGTH_OF_DOC_ID ))
  end

  def report_doc_id=( text )
    write_attribute( :report_doc_id, AppHelper.clean_up( text, MAX_LENGTH_OF_DOC_ID ))
  end

  # access control helper

  def user_is_owner_or_deputy?( id, ags )
    if ags == 0
      ( id == p_owner_id )||( id == p_deputy_id )
    else
      ( id == c_owner_id )||( id == c_deputy_id )
    end
  end

  def permitted_to_access?( id )
#    user_is_owner_or_deputy?( id )||pcp_members.exists?( account: id, to_access: true )
  end

  def permitted_to_update?( id )
#    user_is_owner_or_deputy?( id )||pcp_members.exists?( account: id, to_access: true, to_update: true )
  end

  protected
    
    # when creating a new pcp_subject, we should take the default values from the
    # pcp_category

    def set_defaults_from_pcp_categories
      oc = self.pcp_category
      if oc
        set_default!( :c_group_id, oc.c_group_id )
        set_default!( :p_group_id, oc.p_group_id )
        set_default!( :c_owner_id, oc.c_owner_id )
        set_default!( :p_owner_id, oc.p_owner_id )
        set_default!( :c_deputy_id, oc.c_deputy_id )
        set_default!( :p_deputy_id, oc.p_deputy_id )
      end
    end

end
