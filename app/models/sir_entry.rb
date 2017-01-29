class SirEntry < ActiveRecord::Base
  include ApplicationModel

  belongs_to :sir_item, ->{ readonly }, inverse_of: :sir_entries
  belongs_to :group,    ->{ readonly }
  belongs_to :parent,   ->{ readonly },          class_name: 'SirEntry'
# has_one    :response, ->{ where rec_type: 2 }, class_name: 'SirEntry', foreign_key: 'parent_id'

  before_save :set_depth

  validates :sir_item,
    presence: true

  validates :group,
    presence: true

  validates :parent,
    presence: true, if: Proc.new{ |me| me.parent_id.present? }

  SIR_ENTRY_REC_TYPE_LABELS = SirEntry.human_attribute_name( :rec_types ).freeze

  validates :rec_type,
    presence: true,
    inclusion: { in: 0..2 }

  validates :due_date,
    date_field: { presence: false }

  validate :parent_valid?

  # provide access to labels

  def rec_type_label
    SIR_ENTRY_REC_TYPE_LABELS[ rec_type ] unless rec_type.nil?
  end

  def group_code
    ( group.try :code ) || some_id( group_id )
  end

  private

    # ensure that we have a valid parent here:
    # (a) a response must refer to a request
    # (b) must exist
    # (c) must belong to same SIR Item
    # (d) comment's parent group must be same as own group
    #     or item's group if no parent
    # (e) cannot make request for myself - request must always go to group
    #     other than parent's or item's group

    def parent_valid?
      if parent_id
        unless SirEntry.exists?( parent_id )
          errors.add( :parent_id, I18n.t( 'sir_entries.msg.bad_parent_id' ))
          return
        end
        unless sir_item_id == parent.sir_item_id 
          errors.add( :parent_id, I18n.t( 'sir_entries.msg.bad_cross_ref' ))
          return
        end
      end
      case rec_type
      when 0 # request
        errors.add( :group_id, I18n.t( 'sir_entries.msg.bad_req_group' )) \
          unless ( parent_id && parent.group_id != group_id ) or ( parent_id.nil? && sir_item_id && sir_item.group_id != group_id ) 
      when 1 # comment
        errors.add( :group_id, I18n.t( 'sir_entries.msg.bad_rr_group' )) \
          unless ( parent_id && parent.group_id == group_id ) or ( parent_id.nil? && sir_item_id && sir_item.group_id == group_id )
      when 2 # response
        errors.add( :parent_id, I18n.t( 'sir_entries.msg.bad_rr_combo' )) \
          unless parent_id && parent.rec_type == 0
      end

      sir_item.consistent?( self ) unless sir_item.nil?
    end

    # update internal variables before save

    def set_depth
      if parent_id.nil?
        self.depth = 0
      else
        self.depth = ( rec_type == 0 ) ? parent.depth + 1 : parent.depth
      end
    end


end
