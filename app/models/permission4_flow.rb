class Permission4Flow < ActiveRecord::Base
  include ApplicationModel
  include AccountCheck
  include FeatureCheck
  include Filterable

  belongs_to :account
  belongs_to :feature, -> { readonly }, inverse_of: :permission4_flows

  validates :feature_id,
    presence: true

  validate :given_feature_exists

  validates :account_id,
    presence: true

  validate :given_account_exists

  validates :workflow_id,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :workflow_id

  validates :label,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  # tasklist contains the information which task the current account can
  # access: this is currently implemented as comma-separated string of
  # task ids

  validate :tasklist_contents

  scope :fr_feature, -> ( fid ){ where feature_id: fid }

  # tasklist must be a string of MAX_LENGTH_OF_TASKS_STRING characters
  # consisting of a list of integers

  def tasklist_contents
    if tasklist.nil? then
      return
    elsif tasklist =~ /^\s*\d+\s*(,\s*\d+\s*)*$/ && tasklist == $& then 
      self.tasklist = self.tasklist.split(',').map{ |v| Integer(v) }.uniq.join(',')
    else
      errors[ :base ] << I18n.t( 'permission4_flows.msg.bad_tasklist')
    end
  end

  # use this method to determine if the given record allows access to a specific task

  def permission_for_task?( task )
    tasklist.present? && tasklist.split(',').map{ |v| Integer(v) }.include?( task )
  end

  def permission_for_creation?
    permission_for_task?( 0 )
  end

end
