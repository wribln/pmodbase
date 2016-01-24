require './lib/assets/app_helper.rb'
class Group < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include GroupCategoryCheck
  
  belongs_to  :group_category, -> { readonly }, inverse_of: :groups
  has_many    :accounts
  has_many    :responsibilities
  has_many    :permission4_groups

  validates :code,
    uniqueness: true,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :group_category_id,
    presence: true

  validate :given_group_category_exists

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :notes,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :seqno,
    presence: true,
    numericality: { only_integer: true }

  default_scope { order( code: :asc )}
  scope :as_abbr, -> ( abbr ){ where( 'code LIKE ?', "#{ abbr }%" )}
  scope :as_desc, -> ( desc ){ where( 'label LIKE ?', "%#{ desc }%" )}

  # permitted_groups: scope helper in conjunction with Account.permitted_groups
  # to provide the scope for groups to which user has access to: This will
  # return then all Group records to which the given account is permitted
  # access to according to the conditions specified in the Account.permitted_groups
  # method

  def self.permitted_groups( pg )
    case pg
    when nil
      none
    when ""
      all
    else
      where pg
    end
  end

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks 

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
  end

  def notes=( text )
    write_attribute( :notes, AppHelper.clean_up( text, MAX_LENGTH_OF_NOTES ))
  end

  # overwrite write accessor to ensure that [label] does not contain
  # any redundant blanks

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text, MAX_LENGTH_OF_LABEL ))
  end

  def label_with_id
    text_and_id( :label )
  end

  def code_with_id
    text_and_id( :code )    
  end

  def group_category_with_id
    assoc_text_and_id( :group_category, :label )
  end

end
