# The purpose of these records are to collect delta information of tia_items
# for the display of the history of changes. Since these records are only
# read, no sophisticated update needs to be considered.
#
# The logging of the changes is implemented as serialized hash with the
# changed field name is the key, and the previous value is stored as value
# of the hash. Note that the field names need to be strings as the serialized
# hash does not recognize symbols as keys.

class TiaItemDelta < ActiveRecord::Base
  include ApplicationModel
  
  belongs_to  :tia_item,  -> { readonly }, inverse_of: :tia_item_deltas

  serialize :delta_hash, JSON

  validates :tia_item_id,
    presence: true

  validate :given_tia_item_exists
  validate :delta_hash_not_empty

  default_scope { order( created_at: :desc )}

  # copy all fields which are different in the two TiaItem's
  # if nothing was copied, leave reference to TiaItem (to_tia_item)
  # nil, else set to it to the id of the first item

  FIELDS_TO_COPY = %w(
    description
    comment
    account_id
    prio
    status
    due_date
    archived ).freeze

  # provide helper methods to access fields dynamically

  FIELDS_TO_COPY.each do |f|
    define_method "#{f}_changed?".to_sym do
      delta_hash.try( :has_key?, f )
    end
    define_method f.to_sym do
      delta_hash.try( :fetch, f )
    end
  end

  # collect delta information from two tia items

  def collect_delta_information( from_tia_item, to_tia_item )
    self.delta_hash = Hash.new
    FIELDS_TO_COPY.each do |f|
      if from_tia_item[ f ] != to_tia_item[ f ] then
        self.delta_hash[ f ] = from_tia_item[ f ]
      end
    end

    # set reference to TiaItem only when there were changes
    # to force valid? to fail

    self.tia_item_id = self.delta_hash.empty? ? nil : to_tia_item.id
  end

  def delta_count
    delta_hash.nil? ? 0 : delta_hash.size
  end

  private

    def delta_hash_not_empty
      errors.add( :base, I18n.t( 'our_tia_items.msg.no_change' )) \
        unless delta_hash && !delta_hash.empty?
    end

  # make sure this links backward correctly

    def given_tia_item_exists
      if self.tia_item_id.present?
        errors.add( :tia_item_id, I18n.t( 'our_tia_items.msg.bad_tia_item_id' )) \
          unless TiaItem.exists?( self.tia_item_id )
      end
    end

end
