require './lib/assets/app_helper.rb'
class DsrDocGroup < ActiveRecord::Base
  include ApplicationModel
  include GroupCheck

  belongs_to :group

  # validations

  validates :code,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :title,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_TITLE }

  validates :group_id,
    presence: true

  validate :given_group_exists

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text ))
  end

  def title=( text )
    write_attribute( :title, AppHelper.clean_up( text ))
  end

  # retrieve group code to display in index/show

  def group_code
    ( group.try :code ) || some_id( group_id )
  end

  def code_with_id
    text_and_id( :code )
  end

end
