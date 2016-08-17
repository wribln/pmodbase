require './lib/assets/app_helper.rb'
class Hashtag < ActiveRecord::Base
  include ApplicationModel
  include ActiveModelErrorsAdd
  include Filterable

  before_save { self.sort_code = code.split( '_', 2 ).first }

  HASHTAG_SYNTAX = /\A#[A-Za-z][A-Za-z0-9\_]*\z/.freeze
  HASHTAG_SEARCH = /(#[A-Za-z][A-Za-z0-9\_]*)=?(\d+)?/.freeze

  belongs_to :feature, -> { readonly }

  validates :code,
    presence: true,
    format: { with: HASHTAG_SYNTAX, message: I18n.t( 'hashtags.msg.bad_code_syntax' )},
    uniqueness: { scope: :feature_id, message: I18n.t( 'hashtags.msg.uniq_per_feature' )},
    length: { maximum: MAX_LENGTH_OF_CODE }

  validates :label,
    presence: true,
    length: { maximum: MAX_LENGTH_OF_LABEL }

  validates :seqno,
    presence: true,
    numericality: { only_integer: true }

  validates :feature,
    presence: true

  default_scope { order( feature_id: :asc, sort_code: :asc, seqno: :asc )}
  scope :ff_code,     -> ( c ){ where( 'code LIKE ?', "#{ c }%" )}
  scope :ff_label,    -> ( l ){ where( 'label LIKE ?', "%#{ l }%" )}
  scope :ff_feature,  -> ( f ){ where( feature_id: f )}

  # define some class methods to be used to collect statistics:

  # prepare a hash ready to receive statistics counts

  def self.new_stats
    Hash.new( 0 )
  end

  # scan the given source_string for all hashtag keys and optional
  # values; updated result_hash is returned

  def self.collect_hashstats( source_string, result_hash )
    source_string.scan HASHTAG_SEARCH do | m |
      hash_key = m[ 0 ]
      hash_cnt = m[ 1 ].nil? ? 1 : m[ 1 ].to_i
      hash_grp = hash_key.split( '_', 2 )
      result_hash[ hash_key ] += hash_cnt
      result_hash[ hash_grp[ 0 ]] += hash_cnt if hash_grp.length > 1
    end unless source_string.nil?
  end
  
  # the following is a destructive (hence the !) retrieval of the
  # value, i.e. take it and destroy; useful to mark the entry as
  # 'used'
  
  def self.take_count!( key, result_hash )
    result_hash.delete( key ) || 0
  end
  
  # for listing the hashtags with the counts only, create an
  # array of key-value pairs and sort it by the key
  
  def self.to_sorted_a( result_hash )
    result_hash.to_a.sort_by! {|k| k[0]}
  end

  # collect counts from source_string based on hashtags
  # and return an array of those counts

  def self.collect_hashcounts( source_string, hashtags )
    result_array = Array.new( hashtags.size, 0 )
    if !source_string.blank? && result_array.size > 0 then
      source_string.scan HASHTAG_SEARCH do |m|
        hash_key = m[ 0 ]
        hash_cnt = m[ 1 ].nil?  ? 1 : m[ 1 ].to_i
        hash_grp = hash_key.split( '_', 2 )
        hash_key_index = hashtags.index( hash_key )
        hash_grp_index = hash_grp.length > 1 ? hashtags.index( hash_grp[ 0 ]) : nil
        result_array[ hash_key_index ] += hash_cnt unless hash_key_index.nil?
        result_array[ hash_grp_index ] += hash_cnt unless hash_grp_index.nil?
      end
    end
    return result_array
  end

end
