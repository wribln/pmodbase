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

  # prepare a link to a file, if not title is given, use the uri

  def link_to_file( uri, title = nil )
    l = /\A(https?|file|ftp):\/\//i =~ uri ? uri : "file://#{ uri }" unless uri.blank?
    Rails.logger.debug ">>>>> link_to_file( #{uri}, #{title} ) -> #{l}"
    link_to_if( l, title.nil? ? uri : title, l, target: '_blank' )
  end

end