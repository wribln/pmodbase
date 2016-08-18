require './lib/assets/app_helper.rb'
class DsrDocGroup < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd

  belongs_to :group

  # validations

  validates :code,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :title,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_TITLE }

  validates :group,
    presence: true

  set_trimmed :code, :title

  # retrieve group code to display in index/show

  def group_code
    ( group.try :code ) || some_id( group_id )
  end

  def code_with_id
    text_and_id( :code )
  end

end
