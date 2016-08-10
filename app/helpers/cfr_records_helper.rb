module CfrRecordsHelper

  # prepare to show the relationship of this cfr_record
  # to the other cfr_record as defined in the cfr_relation

  def display_relationship( cfr_relation, cfr_record )
    if cfr_record.id == cfr_relation.src_record_id
      l = cfr_relation.cfr_relationship.label
      d = cfr_relation.dst_record
    else
      l = cfr_relation.cfr_relationship.reverse_rs.label
      d = cfr_relation.src_record
    end
    ( l + '&nbsp;&nbsp;&nbsp;' + link_to( d.to_id + ' ' + d.title, d )).html_safe
  end
end