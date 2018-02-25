class CfrRelation < ActiveRecord::Base
  include ActiveModelErrorsAdd

  belongs_to :src_record, class_name: :CfrRecord, inverse_of: :src_relations
  belongs_to :dst_record, class_name: :CfrRecord, inverse_of: :dst_relations
  belongs_to :cfr_relationship, -> { readonly }

  validates :src_record, :dst_record, :cfr_relationship,
    presence: true

  validate :src_dst_different
  validate :uniqueness_of_relation

  # src_record and dst_record must be different, i.e. a cfr_record must
  # not have a relation with itself

  def src_dst_different
    return if errors.include?( :src_record_id ) || errors.include?( :dst_record_id )
    errors.add( :base, I18n.t( 'cfr_relations.msg.no_self_ref' )) \
      unless src_record != dst_record
  end

  # make sure that we do not have redundant relations, i.e.
  # src - dst - relationship A or A.reverse_rs
  # dst - src - relationship A or A.reverse_rs

  def uniqueness_of_relation
    return unless errors.empty?
    rs = [ cfr_relationship_id, cfr_relationship.reverse_rs.id ]
    rr = [ src_record_id, dst_record_id ]
    ra = CfrRelation.where( src_record_id: rr, dst_record_id: rr, cfr_relationship_id: rs )
    return unless ra.exists?
    return if ra.count == 1 && ra[ 0 ].id = self.id
    errors.add( :base, I18n.t( 'cfr_relations.msg.same_ref' ))
  end

  # provide a label for views

  def get_label( cfr_record )
    return if cfr_record.nil?
    cfr_record.id == src_record.id ? cfr_relationship.label : cfr_relationship.reverse_rs.label
  end

  # provide destination record

  def get_destination( cfr_record )
    return if cfr_record.nil?
    cfr_record.id == src_record.id ? dst_record : src_record
  end

end
