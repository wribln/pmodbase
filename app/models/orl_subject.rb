class OrlSubject < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include OrlSubjectAccess

  belongs_to :orl_category, -> { readonly }, inverse_of: :orl_subjects
  belongs_to :o_group,  -> { readonly }, foreign_key: :o_group_id, class_name: Group
  belongs_to :r_group,  -> { readonly }, foreign_key: :r_group_id, class_name: Group
  belongs_to :o_owner,  -> { readonly }, foreign_key: :o_owner_id, class_name: Account
  belongs_to :r_owner,  -> { readonly }, foreign_key: :r_owner_id, class_name: Account
  belongs_to :o_deputy, -> { readonly }, foreign_key: :o_deputy_id, class_name: Account
  belongs_to :r_deputy, -> { readonly }, foreign_key: :r_deputy_id, class_name: Account
  has_many   :orl_steps, dependent: :destroy, validate: false, inverse_of: :orl_subject
  accepts_nested_attributes_for :orl_steps


  before_validation :set_defaults_from_orl_categories, on: :create

  validates :orl_category_id,
    presence: true

  validates :o_group_id, :o_owner_id, :r_group_id, :r_owner_id,
    presence: true,
    on: :update

  validates :desc,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  validates :note,
    length: { maximum: MAX_LENGTH_OF_NOTE }

  validates :project_doc_id, :report_doc_id,
    length: { maximum: MAX_LENGTH_OF_DOC_ID }

  validate :orl_category_exists

  validate { given_account_has_access( :o_owner_id,  :o_group_id )}
  validate { given_account_has_access( :o_deputy_id, :o_group_id )}
  validate { given_account_has_access( :r_owner_id,  :r_group_id )}
  validate { given_account_has_access( :r_deputy_id, :r_group_id )}

  validate :archived_and_status

  # all_active is used by controller - make sure it matches an index

  scope :all_active, ->{ where( archived: false ).order( orl_category_id: :asc, id: :desc )}

  # make sure that archived status can only be set if subject status is closed

  def archived_and_status
    if archived then
      errors.add( :archived, I18n.t( 'orl_subjects.msg.bad_status' )) \
        unless current_step.status_closed?
    end
  end

  # ensure that the selected/given orl_category really exists

  def orl_category_exists
    unless orl_category_id.nil? then
      errors.add( :orl_category_id, I18n.t( 'orl_subjects.msg.bad_category' )) \
        unless OrlCategory.exists?( orl_category_id )
    end
  end

  # retrieve the current orl_step

  def current_step
    orl_steps.most_recent.first
  end

  # providing the ballpark as parameter is mostly more efficient than 
  # referring to current_step.ballpark as the current_step is mostly 
  # known/retrieved when this method is called

  def acting_group( bp )
    Group.find( bp == 0 ? o_group_id : r_group_id )
  end

  # fix assignments

  def desc=( text )
    write_attribute( :desc, AppHelper.clean_up( text, MAX_LENGTH_OF_DESCRIPTION ))
  end

  def project_doc_id=( text )
    write_attribute( :project_doc_id, AppHelper.clean_up( text, MAX_LENGTH_OF_DOC_ID ))
  end

  def report_doc_id=( text )
    write_attribute( :report_doc_id, AppHelper.clean_up( text, MAX_LENGTH_OF_DOC_ID ))
  end

  protected
    
    # when creating a new orl_subject, we should take the default values from the
    # orl_category

    def set_defaults_from_orl_categories
      oc = self.orl_category
      if oc
        set_default!( :o_group_id, oc.o_group_id )
        set_default!( :r_group_id, oc.r_group_id )
        set_default!( :o_owner_id, oc.o_owner_id )
        set_default!( :r_owner_id, oc.r_owner_id )
        set_default!( :o_deputy_id, oc.o_deputy_id )
        set_default!( :r_deputy_id, oc.r_deputy_id )
      end
    end

end
