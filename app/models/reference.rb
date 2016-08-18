require "./lib/assets/app_helper.rb"
class Reference < ActiveRecord::Base
  include ApplicationModel

  has_many :glossary_items, -> { readonly }, inverse_of: :reference

  validates :code,
    length: { maximum: MAX_LENGTH_OF_CODE },
    uniqueness: true,
    allow_blank: false

  validates :description,
    allow_blank: true,
    length: { maximum: MAX_LENGTH_OF_DESCRIPTION }

  validates :project_doc_id,
    allow_blank: true,
    length: { maximum: ProjectDocLog::MAX_LENGTH_OF_DOC_ID }

  set_trimmed :code, :project_doc_id

  default_scope { order( code: :asc )}

end
