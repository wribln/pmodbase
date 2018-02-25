class CfrRelationship < ActiveRecord::Base
  include ApplicationModel

  has_one :reverse_rs, class_name: :CfrRelationship, foreign_key: :reverse_rs_id, autosave: true
  after_destroy :delete_reverse_rs

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :leading,
    inclusion: { in: [ true, false ]}

  CFR_RS_GROUP_LABELS = CfrRelationship.human_attribute_name( :rs_groups ).freeze

  validates :rs_group,
    presence: true,
    inclusion: { in: (0..2) }

  validate :relationship

  # make sure that the pair is consistent:
  # - must belong to same group
  # - must point back to eachother
  # - one must be leading, the other not

  def relationship
    return if reverse_rs_id.nil?
    r = CfrRelationship.find_by_id( reverse_rs_id )
    if r.nil? then
      errors.add( :reverse_rs_id, I18n.t( 'cfr_relationships.msg.bad_reverse' ))
      return
    end
    if r.reverse_rs_id != id then
      errors.add( :reverse_rs_id, I18n.t( 'cfr_relationships.msg.wrong_reverse' ))
      return
    end
    if r.rs_group != rs_group then
      errors.add( :rs_group, I18n.t( 'cfr_relationships.msg.bad_rs_group' ))
      return
    end
    if r.leading == leading then
      errors.add( :leading, I18n.t( 'cfr_relationships.msg.bad_leading' ))
      return
    end
  end

  # return label of group (if given)

  def rs_group_label
    CFR_RS_GROUP_LABELS[ rs_group ] unless rs_group.nil?
  end

  # prepare list of grouped options for select

  def self.get_option_list
#    { 'Group 1': [[ 'Detail 1.1', 1 ],[ 'Detail 1.2', 2 ]],
#      'Group 2': [[ 'Detail 2.1', 3 ],[ 'Detail 2.2', 4 ]]}
    {}.tap { |h| [ 
      self.all.order( :rs_group ).chunk{ |r| r.rs_group }.each{ |g,i| h[ CFR_RS_GROUP_LABELS[ g ]] =
     i.map{ |i| [i.label,i.id] }}]}
  end

  private
    def delete_reverse_rs
      reverse_rs.delete
    end
  
end
