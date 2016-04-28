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

  default_scope { order( code: :asc )}

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def code=( text )
    write_attribute( :code, AppHelper.clean_up( text, MAX_LENGTH_OF_CODE ))
  end

  def project_doc_id=( text )
    write_attribute( :project_doc_id, AppHelper.clean_up( text, ProjectDocLog::MAX_LENGTH_OF_DOC_ID ))
  end

  # prepare a collection which includes an entry to be used for empty records

  def self.get_select_collection
    [[ I18n.t( 'general.none' ), 0 ]].concat( self.all.pluck( :code, :id ))
  end

end
