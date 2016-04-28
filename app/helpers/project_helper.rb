# THIS is a good place to insert project-specific helper methods

module ProjectHelper

  # this method combines a document code and its version (number)

  def combine_doc_id_and_version( doc_id, version )
    doc_id.to_s << '-' << version.to_s
  end

end