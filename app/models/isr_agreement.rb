require './lib/assets/app_helper.rb'
class IsrAgreement < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable  

  belongs_to :l_group,    -> { readonly },  foreign_key: :l_group_id,   class_name: :Group
  belongs_to :p_group,    -> { readonly },  foreign_key: :p_group_id,   class_name: :Group
  belongs_to :l_owner,    -> { readonly },  foreign_key: :l_owner_id,   class_name: :Account
  belongs_to :l_deputy,   -> { readonly },  foreign_key: :l_deputy_id,  class_name: :Account
  belongs_to :p_owner,    -> { readonly },  foreign_key: :p_owner_id,   class_name: :Account
  belongs_to :p_deputy,   -> { readonly },  foreign_key: :p_deputy_id,  class_name: :Account
  belongs_to :res_steps,                    foreign_key: :res_steps_id, class_name: :TiaList, autosave: true 
  belongs_to :val_steps,                    foreign_key: :val_steps_id, class_name: :TiaList, autosave: true
  belongs_to :based_on,                     foreign_key: :based_on_id,  class_name: :IsrAgreement, autosave: true
  belongs_to :isr_interface, inverse_of: :isr_agreements
  belongs_to :cfr_record

  before_validation :update_tia_lists

  # the following attributes are used only to transfer a request to
  # create or remove res/val_steps TIA lists; set flag to 1 create
  # TIA list, to 0 to remove TIA list; define reader here, writer later

  attr_reader :res_steps_req, :val_steps_req

  after_initialize :initialize_steps_req

  validates :l_group,
    presence: true

  validates :p_group,
    presence: true, if: Proc.new{ |me| me.p_group_id.present? }

  validates :cfr_record,
    presence: true, if: Proc.new{ |me| me.cfr_record_id.present? }

  validates :res_steps,
    presence: true, if: Proc.new{ |me| me.res_steps.present? && !me.res_steps.marked_for_destruction? }

  validates :val_steps,
    presence: true, if: Proc.new{ |me| me.val_steps.present? && !me.val_steps.marked_for_destruction? }

  # owner is needed whenever a TIA list is generated

  validates :l_owner_id,
    presence: true, if: Proc.new{ |me| me.res_steps_req != 0 || me.val_steps_req != 0 }

  validates :l_owner,
    presence: true, if: Proc.new{ |me| me.l_owner_id.present? }

  validates :l_deputy,
    presence: true, if: Proc.new{ |me| me.l_deputy_id.present? }

  validates :p_owner,
    presence: true, if: Proc.new{ |me| me.p_owner_id.present? }

  validates :p_deputy,
    presence: true, if: Proc.new{ |me| me.p_deputy_id.present? }

  # based_on refers back to the previous revision 
  # this is needed to synchronize the status of both revisions

  validates :based_on,
    presence: true, if: Proc.new{ |me| me.based_on_id.present? }

  # ia_type determines workflow:
  # 0 - create new IA
  # 1 - revise existing IA
  # 2 - change status to terminated
  # 3 - change status to resolved
  # 4 - change status to closed

  validates :ia_type,
    allow_blank: false,
    numericality: { only_integer: true },
    inclusion: { in: 0..4 }  

  # status of IAs:

  ISR_IA_STATUS_LABELS = IsrAgreement.human_attribute_name( :ia_states ).freeze
  ISR_IA_STATUS_GROUPS = IsrAgreement.human_attribute_name( :ia_status_groups ).freeze
  ISR_IA_STATUS_ACTIVE = [ 0, 1, 2 ].freeze
  ISR_IA_STATUS_CLOSED = [ 3, 7, 10 ].freeze
  ISR_IA_STATUS_INACTIVE = [ 6, 8, 9 ].freeze
  ISR_IA_STATUS_PENDING = [ 4, 5 ].freeze
  ISR_IA_STATUS_TO_SHOW = [ 0, 1, 2, 3, 4, 5 ].freeze

  validates :ia_status,
    allow_blank: false,
    numericality: { only_integer: true },
    inclusion: { in: 0..( ISR_IA_STATUS_LABELS.size - 1 )}

  validates :current_status,
    allow_blank: false,
    numericality: { only_integer: true },
    inclusion: { in: 0..9 }

  validates :current_task,
    allow_blank: false,
    numericality: { only_integer: true },
    inclusion: { in: 0..6 }

  validates :rev_no,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :ia_no,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validate :ia_type_integrity
  validate :access_permissions

  # default scope is order:

  default_scope { order( isr_interface_id: :asc, ia_no: :asc, rev_no: :asc )}

  # for filtering

  scope :ff_id,  -> ( i ){ where( isr_interface_id: i )}
  scope :ff_txt, -> ( t ){ where( 'def_text LIKE :param', param: "%#{ t }%" )}
  scope :ff_sts, -> ( s ){ where( ia_status: s )}
  scope :ff_wfs, -> ( s ){ where AppHelper.map_values( s, :ia_type, :current_status )}
  scope :ff_grp, -> ( g ){ where( 'l_group_id = :param OR p_group_id = :param', param: g )}

  # search scopes
  
  class << self; 
    alias :for_group :ff_grp
  end

  # IAs to be shown in the ISR index (all active, pending, closed )

  scope :current, ->  { where( ia_status: ISR_IA_STATUS_TO_SHOW)}

  # format IA code for display. IMPORTANT: if you change this code, you may
  # need to adjust the view helper link_to_isa (defined in /helpers/link_helper.rb)

  def code
    sprintf( 'IF-%03d-IA-%s-%s-%s', isr_interface.id, ia_no, l_group.try( :code ), p_group.try( :code )) unless isr_interface_id.nil?
  end

  def revision
    I18n.t( 'activerecord.attributes.isr_agreement.revision_suffix', rev_no: rev_no )
  end

  def code_and_revision
    if rev_no > 0
      code + ' ' + revision
    else
      code
    end
  end

  # prepare new or initial revision, assume that self is copy
  # if ia_type is zero, assume reset to initial, default values

  def prepare_revision( wf, bo = nil )
    self.ia_type = wf
    case wf
    when 0 # new/copy
      self.rev_no = 0
      self.res_steps_req = 0
      self.val_steps_req = 0
      self.initialize_steps_req
      self.cfr_record_id = nil
      self.based_on_id = nil
      self.l_signature = nil
      self.l_sign_time = nil
      self.p_signature = nil
      self.p_sign_time = nil
      set_next_ia_no
    when 1, 2, 3, 4 # revise, terminate, resolve, close
      self.based_on = bo
      self.ia_no = bo.ia_no unless bo.nil?
      self.set_next_rev_no
    end
    self.ia_status = 0 # open
    self.current_status = 0
    self.current_task = 0
  end

  # initialize non-database model attributes

  def initialize_steps_req
    self.res_steps_req = res_steps_id.nil? ? 0 : 1
    self.val_steps_req = val_steps_id.nil? ? 0 : 1
  end

  def res_steps_req=( s )
    @res_steps_req = s.to_i 
  end

  def val_steps_req=( s )
    @val_steps_req = s.to_i
  end

  # create or remove TIA lists, update owners

  def update_tia_lists

    if self.res_steps.nil?
      self.build_res_steps( code: tia_list_code( :res_steps ), label: tia_list_label( :res_steps ), 
        owner_account_id: l_owner_id, deputy_account_id: l_deputy_id ) if res_steps_req != 0
    elsif res_steps_req == 0
      self.res_steps.mark_for_destruction
    else
      self.res_steps.owner_account_id = l_owner_id
      self.res_steps.deputy_account_id = l_deputy_id
    end

    if self.val_steps.nil?
      self.build_val_steps( code: tia_list_code( :val_steps ), label: tia_list_label( :val_steps ), 
          owner_account_id: l_owner_id, deputy_account_id: l_deputy_id ) if val_steps_req != 0
    elsif val_steps_req == 0
      self.val_steps.mark_for_destruction
    else
      self.val_steps.owner_account_id = l_owner_id
      self.val_steps.deputy_account_id = l_deputy_id
    end

  end

  # prepare code and label for related TIA lists

  def tia_list_code( s_list )
    case s_list
    when :res_steps
      s_id = 'RS'
    when :val_steps
      s_id = 'VS'
    else
      raise ArgumentError, 's_list must be :res_steps, :val_steps'
    end
    sprintf( 'IF-%003d-IA-%s-%s', isr_interface.id, ia_no, s_id )
  end

  def tia_list_label( s_list )
    case s_list
    when :res_steps
      s_id = 'res_steps_label'
    when :val_steps
      s_id = 'val_steps_label'
    else
      raise ArgumentError, 's_list must be :res_steps, :val_steps'
    end
    I18n.t( 'activerecord.attributes.isr_agreement.' << s_id, code: code )
  end

  # return the sequence number to use for the next IA

  def set_next_ia_no
    a = self.isr_interface.isr_agreements.select( :ia_no ).distinct
    m = a.maximum( :ia_no ) || 0
    n = a.count
    self.ia_no = ( n > m ? n : m ) + 1
  end

  def set_next_rev_no
    a = self.isr_interface.isr_agreements.where( ia_no: self.ia_no )
    m = a.maximum( :rev_no ) || 0
    n = a.count
    self.rev_no = ( n > m ? n : m + 1 )
  end

  def ia_status_label
    ISR_IA_STATUS_LABELS[ ia_status ] unless ia_status.nil?
  end

  # not possible to modify record when

  def frozen?
    self.ia_status != 0
  end

  # validates based_on relationship:
  # (1) based_on must exist for ia_type > 0
  # (2) related record must refer to same interface
  # (3) revision number must be less than this one;
  # (4) status withdrawn can only occur for rev_no == 0

  def ia_type_integrity

    if self.ia_type > 0
      unless self.based_on_id && IsrAgreement.exists?( self.based_on_id )
        errors.add( :ia_type, I18n.t( 'isr_interfaces.msg.inconsistent', detail: 1 ))
        return
      end
      unless self.based_on.isr_interface.id == self.isr_interface_id
        errors.add( :based_on, I18n.t( 'isr_interfaces.msg.inconsistent', detail: 2 ))
        return
      end
      unless self.based_on.rev_no < self.rev_no
        errors.add( :based_on, I18n.t( 'isr_interfaces.msg.inconsistent', detail: 3 ))
        return
      end
    end
    if self.ia_status == 10
      errors.add( :ia_status, I18n.t( 'isr_interfaces.msg.inconsistent', detail: 4 )) \
        unless self.rev_no == 0
      return
    end

  end

  # check if the given accounts do have access permissions for their role

  def access_permissions

    unless l_group_id.nil?
      unless l_owner_id.nil?
        errors.add( :l_owner_id, I18n.t( 'isr_interfaces.msg.no_access_4' )) \
          unless l_owner.permission_to_access( FEATURE_ID_ISR_INTERFACES, :to_update, l_group_id )
      end
      unless l_deputy_id.nil?
        errors.add( :l_deputy_id, I18n.t( 'isr_interfaces.msg.no_access_4' )) \
          unless l_deputy.permission_to_access( FEATURE_ID_ISR_INTERFACES, :to_update, l_group_id )
      end
    end

    unless p_group_id.nil?
      unless p_owner_id.nil?
        errors.add( :p_owner_id, I18n.t( 'isr_interfaces.msg.no_access_4' )) \
          unless p_owner.permission_to_access( FEATURE_ID_ISR_INTERFACES, :to_update, p_group_id )
      end
      unless p_deputy_id.nil?
        errors.add( :p_deputy_id, I18n.t( 'isr_interfaces.msg.no_access_4' )) \
          unless p_deputy.permission_to_access( FEATURE_ID_ISR_INTERFACES, :to_update, p_group_id )
      end
    end

  end

  # process withdraw request:
  # only change non-terminal states to withdrawn
  # set workflow status to complete / withdrawn

  def withdraw
    if [ 0, 1, 4, 5 ].include? ia_status
      close_ia
      self.ia_status = 10
      self.current_task = 6
      self.current_status = 9
    end
  end

  # perform necessary actions to resolve/close/terminate interface agreement,
  # i.e. mark tia_lists and associated items as archived

  def resolve_ia
    self.ia_status = 2
    self.res_steps.archived = true unless res_steps.nil?
  end    

  def close_ia
    resolve_ia
    self.ia_status = 3
    self.val_steps.archived = true unless res_steps.nil?
  end

  def terminate_ia
    close_ia
    self.ia_status = 7
  end

end
