require 'test_helper'
class ProjectDocLogTest < ActiveSupport::TestCase

# there are some methods which need to be provided by both
# the Siemens and the Alternative Document Log; the following
# ensures that both classes behave the same

  test 'ProjectDocLog must be one of the following' do 
    assert ProjectDocLog == SDocumentLog || ProjectDocLog == ADocumentLog
  end

  [[ SDocumentLog, :s_document_logs, MAX_LENGTH_OF_DOC_ID_S],
   [ ADocumentLog, :a_document_logs, MAX_LENGTH_OF_DOC_ID_A]].each do |pdl|

    test "#{ pdl[ 0 ].name } - get_title_and_doc_id - OK" do
      dl = self.send( pdl[ 1 ], :one )
      da = pdl[ 0 ].get_title_and_doc_id( dl.id )
      assert da.kind_of?( Array )
      assert_equal 2, da.size
      assert_equal da[ 0 ], dl.title 
      assert_equal da[ 1 ], dl.doc_id
    end  
  
    test "#{ pdl[ 0 ].name } - get_title_and_doc_id - not OK" do
      da = pdl[ 0 ].get_title_and_doc_id( 0 )
      assert_nil da
    end

    test "#{ pdl[ 0 ].name } - combine_doc_id_and_version" do
      s = pdl[ 0 ].combine_doc_id_and_version( 'Doc-ID', 'Version' )
      m = /\ADoc-ID(.*)Version\z/.match( s )
      assert_equal s, m[ 0 ]
      sep = m[ 1 ]

      s = pdl[ 0 ].combine_doc_id_and_version( nil, 'Version' )
      m = /\A(.*)Version\z/.match( s )
      assert_equal s, m[ 0 ]
      assert_equal sep, m[ 1 ]

      s = pdl[ 0 ].combine_doc_id_and_version( 'Doc-ID', nil )
      m = /\ADoc-ID(.*)\z/.match( s )
      assert_equal s, m[ 0 ]
      assert_equal sep, m[ 1 ]

      s = pdl[ 0 ].combine_doc_id_and_version( nil, nil )
      assert_equal s, sep
    end
  
    test "maximum length of #{ pdl[ 0 ].name } doc_id" do
      assert_equal pdl[ 0 ]::MAX_LENGTH_OF_DOC_ID, pdl[ 2 ]
    end

  end

end