require "./lib/assets/app_helper.rb"
class GroupCategory < ActiveRecord::Base
  include ApplicationModel

  has_many :groups, dependent: :destroy, inverse_of: :group_category

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL },
    presence: true

  validates :seqno,
    presence: true,
    numericality: { only_integer: true }

  # overwrite write accessor to ensure that [label] does not contain
  # any redundant blanks

  def label=( text )
    write_attribute( :label, AppHelper.clean_up( text ))
  end

end
