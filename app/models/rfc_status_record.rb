require './lib/assets/app_helper.rb'
class RfcStatusRecord < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable

  belongs_to :asking_group,    -> { readonly }, foreign_key: 'asking_group_id',    class_name: 'Group'
  belongs_to :answering_group, -> { readonly }, foreign_key: 'answering_group_id', class_name: 'Group'
  has_many   :rfc_documents, inverse_of: :rfc_status_record

  # cannot use accepts_nested_attributes_for :rfc_documents here
  # because this would cause automatic update of :rfc_document
  # data in nested forms. I need to handle this manually to
  # ensure that related RfcDocuments are never updated but
  # have new versions created when something was changed.

  validates :rfc_type,
    allow_blank: false,
    numericality: { only_integer: true },
    inclusion: { in: 0..2 }

  validates :asking_group,
    presence: true, if: Proc.new{ |me| me.asking_group_id.present? }

  validates :answering_group,
    presence: true, if: Proc.new{ |me| me.answering_group_id.present? }

  validates :title,
    allow_blank: true,
    length: { maximum: MAX_LENGTH_OF_TITLE }

  validates :project_doc_id,
    allow_blank: true,
    length: { maximum: ProjectDocLog::MAX_LENGTH_OF_DOC_ID }

  validates :project_rms_id,
    allow_blank: true,
    length: { maximum: MAX_LENGTH_OF_RMS_ID }

  validates :asking_group_doc_id,
    allow_blank: true,
    length: { maximum: MAX_LENGTH_OF_DOC_ID }

  validates :answering_group_doc_id,
    allow_blank: true,
    length: { maximum: MAX_LENGTH_OF_DOC_ID }

  validates :current_status,
    allow_blank: false,
    numericality: { only_integer: true },
    inclusion: { in: 0..13 }

  validates :current_task,
    allow_blank: false,
    numericality: { only_integer: true },
    inclusion: { in: 0..9 }

  scope :ff_id,   -> ( id   ){ where id:              id   }
  scope :ff_type, -> ( type ){ where rfc_type:        type }
  scope :ff_agrp, -> ( agrp ){ where asking_group:    agrp }
  scope :ff_rgrp, -> ( rgrp ){ where answering_group: rgrp }
  scope :ff_titl, -> ( titl ){ where( 'title LIKE ?', "%#{ titl }%" )}
  scope :ff_stts, -> ( stts ){ where AppHelper.map_values( stts, :rfc_type, :current_status )}

  # retrieve group_code to display in index/show

  def asking_group_code
    ( asking_group.try :code_with_id ) || some_id( asking_group_id )
  end  

  def answering_group_code
    ( answering_group.try :code_with_id ) || some_id( answering_group_id )
  end

  # overwrite write accessors to ensure that text fields do not contain
  # any redundant blanks

  def project_doc_id=( text )
    write_attribute( :project_doc_id, AppHelper.clean_up( text ))
  end

  def project_rms_id=( text )
    write_attribute( :project_rms_id, AppHelper.clean_up( text ))
  end

  def asking_group_doc_id=( text )
    write_attribute( :asking_group_doc_id, AppHelper.clean_up( text ))
  end

  def answering_group_doc_id=( text )
    write_attribute( :answering_group_doc_id, AppHelper.clean_up( text ))
  end

end