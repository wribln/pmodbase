require './lib/assets/app_helper.rb'
class SDocumentLog < ActiveRecord::Base
  include ApplicationModel
  include Filterable
  include AccountCheck
  include GroupCheck

  belongs_to :account, -> { readonly }
  belongs_to :group,   -> { readonly }

  before_save do
    self.siemens_doc_id = create_siemens_doc_id
  end

  validates :group_id,
    presence: true

  validates :receiver_group,
    :function_code,
    :service_code,
    :product_code,
    :location_code,
    :phase_code,
    :revision_code,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :dcc_code,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :author_date,
    date_field: { presence: false }

  validates :siemens_doc_id,
    length: { maximum: MAX_LENGTH_OF_DOC_ID_S }

  validate :given_account_exists
  validate :given_group_exists
  validate :at_least_one_given

  scope :reverse, -> { order( id: :desc )}
  scope :inorder, -> { order( id: :asc  )}
  scope :ff_srec, -> ( id   ){ where id: id }
  scope :ff_sdic, -> ( sdic ){ where( 'siemens_doc_id LIKE ? ESCAPE \'\\\'', "%#{ sanitize_sql_like( sdic, '\\' )}%" )}
  scope :ff_titl, -> ( titl ){ where( 'title LIKE ?', "%#{ titl }%" )}

  # check that at least one of the attribute codes are given

  def at_least_one_given
    errors.add( :base, I18n.t( 's_document_logs.msg.at_least_one' )) \
      if function_code.blank? && service_code.blank? && product_code.blank? && phase_code.blank?
  end

  # create siemens document code

  def create_siemens_doc_id
    '' << SITE_NAME << '(' << group.code << 
    ( receiver_group.blank? ? '' : ')' << receiver_group )<<
    function_code.to_s <<
    service_code.to_s << 
    product_code.to_s <<
    location_code.to_s <<
    phase_code.to_s <<
    dcc_code <<
    ( author_date.nil? ? '' : '_' << author_date.strftime( '%Y%m%d' )) <<
    '_TDD' << sprintf( "%5.5d", id || 0 ) <<
    ( revision_code.blank? ? '' : '_' << revision_code )
  end

end
