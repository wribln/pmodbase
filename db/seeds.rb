# - - - - - - - - - - all feature groups

fc1 = FeatureCategory.new
fc1.label = 'Administration'
fc1.seqno = 1
fc1.save

fc7 = FeatureCategory.new
fc7.label = 'Siemens Codes'
fc7.seqno = 2
fc7.save

fc8 = FeatureCategory.new
fc8.label = 'Alternate Codes'
fc8.seqno = 3
fc8.save

fc2 = FeatureCategory.new
fc2.label = 'Rosters'
fc2.seqno = 4
fc2.save

fc3 = FeatureCategory.new
fc3.label = 'General Information'
fc3.seqno = 5
fc3.save

fc4 = FeatureCategory.new
fc4.label = 'Registers'
fc4.seqno = 6
fc4.save

fc5 = FeatureCategory.new
fc5.label = 'Collaboration'
fc5.seqno = 7
fc5.save

fc6 = FeatureCategory.new
fc6.label = 'Utilities'
fc6.seqno = 8
fc6.save

fc9 = FeatureCategory.new
fc9.label = 'Network Information'
fc9.seqno = 9
fc9.save

puts ">>> no of feature groups: #{ FeatureCategory.count }"

# - - - - - - - - - - all features

Feature.new do |f|
  f.id = FEATURE_ID_PEOPLE
  f.label = I18n.t('people.title')
  f.code = 'APT'
  f.seqno = 1
  f.access_level = PeopleController.feature_access_level
  f.control_level = PeopleController.feature_control_level
  f.no_workflows = PeopleController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_FEATURE_CATEGORIES
  f.label = I18n.t('feature_categories.title')
  f.code = 'FCT'
  f.seqno = 81
  f.access_level = FeatureCategoriesController.feature_access_level
  f.control_level = FeatureCategoriesController.feature_control_level
  f.no_workflows = FeatureCategoriesController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_FEATURE_ITEMS
  f.label = I18n.t('features.title')
  f.code = 'FIT'
  f.seqno = 82
  f.access_level = FeaturesController.feature_access_level
  f.control_level = FeaturesController.feature_control_level
  f.no_workflows = FeaturesController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_RESPONSIBILITIES
  f.label = I18n.t('responsibilities.title')
  f.code = 'RPP'
  f.seqno = 0
  f.access_level = ResponsibilitiesController.feature_access_level
  f.control_level = ResponsibilitiesController.feature_control_level
  f.no_workflows = ResponsibilitiesController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_GROUP_CATEGORIES
  f.label = I18n.t('group_categories.title')
  f.code = 'GCT'
  f.seqno = 61
  f.access_level = GroupCategoriesController.feature_access_level
  f.control_level = GroupCategoriesController.feature_control_level
  f.no_workflows = GroupCategoriesController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_CONTACT_INFOS
  f.label = I18n.t('contact_infos.title')
  f.code = 'CCI'
  f.seqno = 91
  f.access_level = ContactInfosController.feature_access_level
  f.control_level = ContactInfosController.feature_control_level
  f.no_workflows = ContactInfosController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_ACCOUNTS_AND_PERMISSIONS
  f.label = I18n.t('accounts.title')
  f.code = 'ANP'
  f.seqno = 1
  f.access_level = AccountsController.feature_access_level
  f.control_level = AccountsController.feature_control_level
  f.no_workflows = AccountsController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_WORKFLOW_PERMISSIONS
  f.label = I18n.t( 'permission4_flows.title' )
  f.code = 'WRQ'
  f.seqno = 3
  f.access_level = WorkflowResponsibilitiesController.feature_access_level
  f.control_level = WorkflowResponsibilitiesController.feature_control_level
  f.no_workflows = WorkflowResponsibilitiesController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_DBSTATS
  f.label = I18n.t('statistics.title')
  f.code = 'SDH'
  f.seqno = 71
  f.access_level = StatisticsController.feature_access_level
  f.control_level = StatisticsController.feature_control_level
  f.no_workflows = StatisticsController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_DSR_SUBMISSIONS
  f.label = I18n.t( 'dsr_submissions.title' )
  f.code = 'DSB'
  f.seqno = 61
  f.access_level = DsrSubmissionsController.feature_access_level
  f.control_level = DsrSubmissionsController.feature_control_level
  f.no_workflows = DsrSubmissionsController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_DB_CHANGE_REQUESTS
  f.label = I18n.t('db_change_requests.title')
  f.code = 'ACR'
  f.seqno = 41
  f.access_level = DbChangeRequestsController.feature_access_level
  f.control_level = DbChangeRequestsController.feature_control_level
  f.no_workflows = DbChangeRequestsController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_HOME_PAGE
  f.label = I18n.t('home.title')
  f.code = 'PHP'
  f.seqno = 11
  f.access_level = HomeController.feature_access_level
  f.control_level = HomeController.feature_control_level
  f.no_workflows = HomeController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_BASE_PAGE
  f.label = I18n.t('base.title')
  f.code = 'IBP'
  f.seqno = 12
  f.access_level = BaseController.feature_access_level
  f.control_level = BaseController.feature_control_level
  f.no_workflows = BaseController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_HELP_PAGES
  f.label = I18n.t('help_pages.title')
  f.code = 'IHP'
  f.label = 'Help Information'
  f.seqno = 13
  f.access_level = HelpPagesController.feature_access_level
  f.control_level = HelpPagesController.feature_control_level
  f.no_workflows = HelpPagesController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_PROFILE
  f.label = I18n.t('profiles.title')
  f.code = 'IMP'
  f.seqno = 14
  f.access_level = ProfilesController.feature_access_level
  f.control_level = ProfilesController.feature_control_level
  f.no_workflows = ProfilesController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_RFC_DOCUMENTS
  f.label = I18n.t('rfc_documents.title')
  f.code = 'RCD'
  f.seqno = 31
  f.access_level = RfcDocumentsController.feature_access_level
  f.control_level = RfcDocumentsController.feature_control_level
  f.no_workflows = RfcDocumentsController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_REGION_NAMES
  f.label = I18n.t('region_names.title')
  f.code = 'RNC'
  f.seqno = 21
  f.access_level = RegionNamesController.feature_access_level
  f.control_level = RegionNamesController.feature_control_level
  f.no_workflows = RegionNamesController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_SIEMENS_PHASES
  f.label = I18n.t('siemens_phases.title')
  f.code = 'SPC'
  f.seqno = 22
  f.access_level = SiemensPhasesController.feature_access_level
  f.control_level = SiemensPhasesController.feature_control_level
  f.no_workflows = SiemensPhasesController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_ALL_TIA_LISTS
  f.label = I18n.t( 'all_tia_lists.title' )
  f.code = 'ATL'
  f.seqno = 35
  f.access_level = AllTiaListsController.feature_access_level
  f.control_level = AllTiaListsController.feature_control_level
  f.no_workflows = AllTiaListsController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_OUR_TIA_ITEMS
  f.label = I18n.t( 'our_tia_items.title' )
  f.code = 'OTI'
  f.seqno = 36
  f.access_level = OurTiaItemsController.feature_access_level
  f.control_level = OurTiaItemsController.feature_control_level
  f.no_workflows = OurTiaItemsController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_HASHTAGS
  f.label = I18n.t( 'hashtags.title' )
  f.code = 'HTG'
  f.seqno = 41
  f.access_level = HashtagsController.feature_access_level
  f.control_level = HashtagsController.feature_control_level
  f.no_workflows = HashtagsController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_CFR_RELATIONSHIPS
  f.label = I18n.t( 'cfr_relationships.title' )
  f.code = 'CFS'
  f.seqno = 52
  f.access_level = CfrRelationshipsController.feature_access_level
  f.control_level = CfrRelationshipsController.feature_control_level
  f.no_workflows = CfrRelationshipsController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_CFR_FILE_TYPES
  f.label = I18n.t( 'cfr_file_types.title' )
  f.code = 'CFT'
  f.seqno = 51
  f.access_level = CfrFileTypesController.feature_access_level
  f.control_level = CfrFileTypesController.feature_control_level
  f.no_workflows = CfrFileTypesController.no_workflows
  f.feature_category_id = fc1.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_CFR_LOCATION_TYPES
  f.label = I18n.t( 'cfr_location_types.title' )
  f.code = 'CFU'
  f.seqno = 53
  f.access_level = CfrLocationTypesController.feature_access_level
  f.control_level = CfrLocationTypesController.feature_control_level
  f.no_workflows = CfrLocationTypesController.no_workflows
  f.feature_category_id = fc1.id
end.save!

# -  -  -  -  -  -  - Rosters

Feature.new do |f|
  f.id = FEATURE_ID_CONTACT_LISTS
  f.label = I18n.t('contact_lists.title')
  f.code = 'CDL'
  f.seqno =  1
  f.access_level = ContactListsController.feature_access_level
  f.control_level = ContactListsController.feature_control_level
  f.no_workflows = ContactListsController.no_workflows
  f.feature_category_id = fc2.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_ADDRESSES
  f.label = I18n.t('addresses.title')
  f.code = 'ADT'
  f.seqno = 2
  f.access_level = AddressesController.feature_access_level
  f.control_level = AddressesController.feature_control_level
  f.no_workflows = AddressesController.no_workflows
  f.feature_category_id = fc2.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_GROUPS
  f.label = I18n.t('groups.title')
  f.code = 'GRP'
  f.seqno = 3
  f.access_level = GroupsController.feature_access_level
  f.control_level = GroupsController.feature_control_level
  f.no_workflows = GroupsController.no_workflows
  f.feature_category_id = fc2.id
end.save!

# -  -  -  -  -  -  - General Information

Feature.new do |f|
  f.id = FEATURE_ID_ABBR_SEARCH
  f.label = I18n.t('abbr_search.title')
  f.code = 'SFA'
  f.seqno = 1
  f.access_level = AbbrSearchController.feature_access_level
  f.control_level = AbbrSearchController.feature_control_level
  f.no_workflows = AbbrSearchController.no_workflows
  f.feature_category_id = fc3.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_ABBREVIATIONS
  f.label = I18n.t('abbreviations.title')
  f.code = 'AAA'
  f.seqno = 2
  f.access_level = AbbreviationsController.feature_access_level
  f.control_level = AbbreviationsController.feature_control_level
  f.no_workflows = AbbreviationsController.no_workflows
  f.feature_category_id = fc3.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_COUNTRY_NAMES
  f.label = I18n.t('country_names.title')
  f.code = 'CNC'
  f.seqno = 3
  f.access_level = CountryNamesController.feature_access_level
  f.control_level = CountryNamesController.feature_control_level
  f.no_workflows = CountryNamesController.no_workflows
  f.feature_category_id = fc3.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_STANDARDS_BODIES
  f.label = I18n.t('standards_bodies.title')
  f.code = 'SSO'
  f.seqno = 4
  f.access_level = StandardsBodiesController.feature_access_level
  f.control_level = StandardsBodiesController.feature_control_level
  f.no_workflows = StandardsBodiesController.no_workflows
  f.feature_category_id = fc3.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_GLOSSARY
  f.label = I18n.t('glossary_items.title')
  f.code = 'GLO'
  f.seqno = 5
  f.access_level = GlossaryItemsController.feature_access_level
  f.control_level = GlossaryItemsController.feature_control_level
  f.no_workflows = GlossaryItemsController.no_workflows
  f.feature_category_id = fc3.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_REFERENCES
  f.label = I18n.t('references.title')
  f.code = 'REF'
  f.seqno = 6
  f.access_level = ReferencesController.feature_access_level
  f.control_level = ReferencesController.feature_control_level
  f.no_workflows = ReferencesController.no_workflows
  f.feature_category_id = fc3.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_HOLIDAYS
  f.label = I18n.t('holidays.title')
  f.code = 'HLD'
  f.seqno = 7
  f.access_level = HolidaysController.feature_access_level
  f.control_level = HolidaysController.feature_control_level
  f.no_workflows = HolidaysController.no_workflows
  f.feature_category_id = fc3.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_UNIT_NAMES
  f.label = I18n.t('unit_names.title')
  f.code = 'UNC'
  f.seqno = 8
  f.access_level = UnitNamesController.feature_access_level
  f.control_level = UnitNamesController.feature_control_level
  f.no_workflows = UnitNamesController.no_workflows
  f.feature_category_id = fc3.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_WEB_LINKS
  f.label = I18n.t( 'web_links.title' )
  f.code = 'WLK'
  f.seqno = 10
  f.access_level = WebLinksController.feature_access_level
  f.control_level = WebLinksController.feature_control_level
  f.no_workflows = WebLinksController.no_workflows
  f.feature_category_id = fc3.id
end.save!

# -  -  -  -  -  -  - Registers  

Feature.new do |f|
  f.id = FEATURE_ID_CSR_STATUS_RECORDS
  f.label = I18n.t( 'csr_status_records.title' )
  f.code = 'CSR'
  f.seqno = 1
  f.access_level = CsrStatusRecordsController.feature_access_level
  f.control_level = CsrStatusRecordsController.feature_control_level
  f.no_workflows = CsrStatusRecordsController.no_workflows
  f.feature_category_id = fc4.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_CFR_RECORDS
  f.label = I18n.t( 'cfr_records.title' )
  f.code = 'CFR'
  f.seqno = 2
  f.access_level = CfrRecordsController.feature_access_level
  f.control_level = CfrRecordsController.feature_control_level
  f.no_workflows = CfrRecordsController.no_workflows
  f.feature_category_id = fc4.id
end.save! 

Feature.new do |f|
  f.id = FEATURE_ID_DSR_STATUS_RECORDS
  f.label = I18n.t('dsr_status_records.title')
  f.code = 'DSR'
  f.seqno = 3
  f.access_level = DsrStatusRecordsController.feature_access_level
  f.control_level = DsrStatusRecordsController.feature_control_level
  f.no_workflows = DsrStatusRecordsController.no_workflows
  f.feature_category_id = fc4.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_DSR_DOC_GROUPS
  f.label = I18n.t('dsr_doc_groups.title')
  f.code = 'DDG'
  f.seqno = 4
  f.access_level = DsrDocGroupsController.feature_access_level
  f.control_level = DsrDocGroupsController.feature_control_level
  f.no_workflows = DsrDocGroupsController.no_workflows
  f.feature_category_id = fc4.id
end.save!  

Feature.new do |f|
  f.id = FEATURE_ID_DSR_PROGRESS_RATES
  f.label = I18n.t( 'dsr_progress_rates.title' )
  f.code = 'DPR'
  f.seqno = 5
  f.access_level = DsrProgressRatesController.feature_access_level
  f.control_level = DsrProgressRatesController.feature_control_level
  f.no_workflows = DsrProgressRatesController.no_workflows
  f.feature_category_id = fc4.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_SUBMISSION_GROUPS
  f.label = I18n.t('submission_groups.title')
  f.code = 'SGP'
  f.seqno = 6
  f.access_level = SubmissionGroupsController.feature_access_level
  f.control_level = SubmissionGroupsController.feature_control_level
  f.no_workflows = SubmissionGroupsController.no_workflows
  f.feature_category_id = fc4.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_RFC_STATUS_RECORDS
  f.label = I18n.t('rfc_status_records.title')
  f.code = 'RSR'
  f.seqno = 7
  f.access_level = RfcStatusRecordsController.feature_access_level
  f.control_level = RfcStatusRecordsController.feature_control_level
  f.no_workflows = RfcStatusRecordsController.no_workflows
  f.feature_category_id = fc4.id
end.save!

# -  -  -  -  -  -  - Collaboration Tools 

Feature.new do |f|
  f.id = FEATURE_ID_MY_TIA_LISTS
  f.label = I18n.t( 'my_tia_lists.title' )
  f.code = 'MTL'
  f.seqno = 1
  f.access_level = MyTiaListsController.feature_access_level
  f.control_level = MyTiaListsController.feature_control_level
  f.no_workflows = MyTiaListsController.no_workflows
  f.feature_category_id = fc5.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_MY_TIA_ITEMS
  f.label = I18n.t( 'my_tia_items.title' )
  f.code = 'MTI'
  f.seqno = 2
  f.access_level = MyTiaItemsController.feature_access_level
  f.control_level = MyTiaItemsController.feature_control_level
  f.no_workflows = MyTiaItemsController.no_workflows
  f.feature_category_id = fc5.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_PCP_CATEGORIES
  f.label = I18n.t( 'pcp_categories.title' )
  f.code = 'PCC'
  f.seqno = 3
  f.access_level = PcpCategoriesController.feature_access_level
  f.control_level = PcpCategoriesController.feature_control_level
  f.no_workflows = PcpCategoriesController.no_workflows
  f.feature_category_id = fc5.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_ALL_PCP_SUBJECTS
  f.label = I18n.t( 'pcp_all_subjects.title' )
  f.code = 'PCA'
  f.seqno = 4
  f.access_level = PcpAllSubjectsController.feature_access_level
  f.control_level = PcpAllSubjectsController.feature_control_level
  f.no_workflows = PcpAllSubjectsController.no_workflows
  f.feature_category_id = fc5.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_MY_PCP_SUBJECTS
  f.label = I18n.t( 'pcp_subjects.title' )
  f.code = 'PCS'
  f.seqno = 5
  f.access_level = PcpSubjectsController.feature_access_level
  f.control_level = PcpSubjectsController.feature_control_level
  f.no_workflows = PcpSubjectsController.no_workflows
  f.feature_category_id = fc5.id
end.save!

# - - - - - - - - - - utilities

Feature.new do |f|
  f.id = FEATURE_ID_FEATURE_RESP
  f.label = I18n.t('feature_responsibilities.title')
  f.code = 'FRQ'
  f.seqno = 1
  f.access_level = FeatureResponsibilitiesController.feature_access_level
  f.control_level = FeatureResponsibilitiesController.feature_control_level
  f.no_workflows = FeatureResponsibilitiesController.no_workflows
  f.feature_category_id = fc6.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_ACTIVITIES
  f.label = I18n.t( 'programme_activities.title' )
  f.code = 'PPA'
  f.seqno = 2
  f.access_level = ProgrammeActivitiesController.feature_access_level
  f.control_level = ProgrammeActivitiesController.feature_control_level
  f.no_workflows = ProgrammeActivitiesController.no_workflows
  f.feature_category_id = fc6.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_MY_CHANGE_REQUESTS
  f.label = I18n.t('my_change_requests.title')
  f.code = 'MCR'
  f.seqno = 3
  f.access_level = MyChangeRequestsController.feature_access_level
  f.control_level = MyChangeRequestsController.feature_control_level
  f.no_workflows = MyChangeRequestsController.no_workflows
  f.feature_category_id = fc6.id
end.save!

# - - - - - - - - - - codes

Feature.new do |f|
  f.id = FEATURE_ID_S_CODE_SEARCH
  f.label = I18n.t('s_code_search.title')
  f.code = 'SCS'
  f.seqno = 1
  f.access_level = SCodeSearchController.feature_access_level
  f.control_level = SCodeSearchController.feature_control_level
  f.no_workflows = SCodeSearchController.no_workflows
  f.feature_category_id = fc7.id
end.save!

#Feature.new do |f|
#  f.id = FEATURE_ID_DC1_CODES
#  f.label = I18n.t( 'dc1_codes.title' )
#  f.code = 'SC1'
#  f.seqno = 1
#  f.access_level = Dc1CodesController.feature_access_level
#  f.control_level = Dc1CodesController.feature_control_level
#  f.no_workflows = Dc1CodesController.no_workflows
#  f.feature_category_id = fc7.id
#end.save!

Feature.new do |f|
  f.id = FEATURE_ID_FUNCTION_CODES
  f.label = I18n.t( 'function_codes.title' )
  f.code = 'SCF'
  f.seqno = 3
  f.access_level = FunctionCodesController.feature_access_level
  f.control_level = FunctionCodesController.feature_control_level
  f.no_workflows = FunctionCodesController.no_workflows
  f.feature_category_id = fc7.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_SERVICE_CODES
  f.label = I18n.t( 'service_codes.title' )
  f.code = 'SCV'
  f.seqno = 4
  f.access_level = ServiceCodesController.feature_access_level
  f.control_level = ServiceCodesController.feature_control_level
  f.no_workflows = ServiceCodesController.no_workflows
  f.feature_category_id = fc7.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_PRODUCT_CODES
  f.label = I18n.t( 'product_codes.title' )
  f.code = 'SCP'
  f.seqno = 5
  f.access_level = ProductCodesController.feature_access_level
  f.control_level = ProductCodesController.feature_control_level
  f.no_workflows = ProductCodesController.no_workflows
  f.feature_category_id = fc7.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_LOCATION_CODES
  f.label = I18n.t( 'location_codes.title' )
  f.code = 'SCL'
  f.seqno = 6
  f.access_level = LocationCodesController.feature_access_level
  f.control_level = LocationCodesController.feature_control_level
  f.no_workflows = LocationCodesController.no_workflows
  f.feature_category_id = fc7.id
end.save!  

Feature.new do |f|
  f.id = FEATURE_ID_PHASE_CODES
  f.label = I18n.t( 'phase_codes.title' )
  f.code = 'PPC'
  f.seqno = 7
  f.access_level = PhaseCodesController.feature_access_level
  f.control_level = PhaseCodesController.feature_control_level
  f.no_workflows = PhaseCodesController.no_workflows
  f.feature_category_id = fc7.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_DCC_CODES
  f.label = I18n.t( 'dcc_codes.title' )
  f.code = 'SC2'
  f.seqno = 8
  f.access_level = DccCodesController.feature_access_level
  f.control_level = DccCodesController.feature_control_level
  f.no_workflows = DccCodesController.no_workflows
  f.feature_category_id = fc7.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_S_DOCUMENT_LOG
  f.label = I18n.t( 's_document_logs.title' )
  f.code = 'SDL'
  f.seqno = 9
  f.access_level = SDocumentLogsController.feature_access_level
  f.control_level = SDocumentLogsController.feature_control_level
  f.no_workflows = SDocumentLogsController.no_workflows
  f.feature_category_id = fc7.id
end.save!

# - - - - - - - - - - network information

Feature.new do |f|
  f.id = FEATURE_ID_NW_LINES
  f.label = I18n.t( 'network_lines.title' )
  f.code = 'NLN'
  f.seqno = 1
  f.access_level = NetworkLinesController.feature_access_level
  f.control_level = NetworkLinesController.feature_control_level
  f.no_workflows = NetworkLinesController.no_workflows
  f.feature_category_id = fc9.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_NW_STATIONS
  f.label = I18n.t( 'network_stations.title' )
  f.code = 'NST'
  f.seqno = 2
  f.access_level = NetworkStationsController.feature_access_level
  f.control_level = NetworkStationsController.feature_control_level
  f.no_workflows = NetworkStationsController.no_workflows
  f.feature_category_id = fc9.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_NW_STOPS
  f.label = I18n.t( 'network_stops.title' )
  f.code = 'NSO'
  f.seqno = 3
  f.access_level = NetworkStopsController.feature_access_level
  f.control_level = NetworkStopsController.feature_control_level
  f.no_workflows = NetworkStopsController.no_workflows
  f.feature_category_id = fc9.id
end.save!

# - - - - - - - - - - alternative/ACONEX codes

Feature.new do |f|
  f.id = FEATURE_ID_A_CODE_SEARCH
  f.label = I18n.t('a_code_search.title')
  f.code = 'ACS'
  f.seqno = 1
  f.access_level = ACodeSearchController.feature_access_level
  f.control_level = ACodeSearchController.feature_control_level
  f.no_workflows = ACodeSearchController.no_workflows
  f.feature_category_id = fc8.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_A1_CODE
  f.label = I18n.t( 'a1_codes.title' )
  f.code = 'A1C'
  f.seqno = 11
  f.access_level = A1CodesController.feature_access_level
  f.control_level = A1CodesController.feature_control_level
  f.no_workflows = A1CodesController.no_workflows
  f.feature_category_id = fc8.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_A2_CODE
  f.label = I18n.t( 'a2_codes.title' )
  f.code = 'A2C'
  f.seqno = 12
  f.access_level = A2CodesController.feature_access_level
  f.control_level = A2CodesController.feature_control_level
  f.no_workflows = A2CodesController.no_workflows
  f.feature_category_id = fc8.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_A3_CODE
  f.label = I18n.t( 'a3_codes.title' )
  f.code = 'A3C'
  f.seqno = 13
  f.access_level = A3CodesController.feature_access_level
  f.control_level = A3CodesController.feature_control_level
  f.no_workflows = A3CodesController.no_workflows
  f.feature_category_id = fc8.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_A4_CODE
  f.label = I18n.t( 'a4_codes.title' )
  f.code = 'A4C'
  f.seqno = 14
  f.access_level = A4CodesController.feature_access_level
  f.control_level = A4CodesController.feature_control_level
  f.no_workflows = A4CodesController.no_workflows
  f.feature_category_id = fc8.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_A5_CODE
  f.label = I18n.t( 'a5_codes.title' )
  f.code = 'A5C'
  f.seqno = 15
  f.access_level = A5CodesController.feature_access_level
  f.control_level = A5CodesController.feature_control_level
  f.no_workflows = A5CodesController.no_workflows
  f.feature_category_id = fc8.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_A6_CODE
  f.label = I18n.t( 'a6_codes.title' )
  f.code = 'A6C'
  f.seqno = 16
  f.access_level = A6CodesController.feature_access_level
  f.control_level = A6CodesController.feature_control_level
  f.no_workflows = A6CodesController.no_workflows
  f.feature_category_id = fc8.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_A7_CODE
  f.label = I18n.t( 'a7_codes.title' )
  f.code = 'A7C'
  f.seqno = 17
  f.access_level = A7CodesController.feature_access_level
  f.control_level = A7CodesController.feature_control_level
  f.no_workflows = A7CodesController.no_workflows
  f.feature_category_id = fc8.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_A8_CODE
  f.label = I18n.t( 'a8_codes.title' )
  f.code = 'A8C'
  f.seqno = 18
  f.access_level = A8CodesController.feature_access_level
  f.control_level = A8CodesController.feature_control_level
  f.no_workflows = A8CodesController.no_workflows
  f.feature_category_id = fc8.id
end.save!

Feature.new do |f|
  f.id = FEATURE_ID_A_DOCUMENT_LOG
  f.label = I18n.t( 'a_document_logs.title' )
  f.code = 'ADL'
  f.seqno = 21
  f.access_level = ADocumentLogsController.feature_access_level
  f.control_level = ADocumentLogsController.feature_control_level
  f.no_workflows = ADocumentLogsController.no_workflows
  f.feature_category_id = fc8.id
end.save!

puts ">>> last feature added"
puts ">>> no of features: #{ Feature.count }"

# - - - - - - - - - - initial / root user

p1 = Person.new
p1.informal_name = 'Admin'
p1.formal_name = 'Administrator'
p1.email = 'wilfried.roemer@siemens.com'
p1.save

p2 = Person.new
p2.informal_name = 'Tester'
p2.formal_name = 'Mr Nice Guy'
p2.email = 'tester@pmodbase.com'
p2.save

# - - - - - - - - - - contact information / root user

ad = Address.new
ad.label = 'BlnN101'
ad.street_address = "Nonnendammallee 101\n13629 Berlin\nGermany"
ad.save

ci = ContactInfo.new
ci.info_type = 'Company'
ci.department = 'MO TPE PMO PAE TPM'
ci.detail_location = 'D 5127'
ci.address_id = ad.id
ci.phone_no_fixed = '+49 30 386 52756'
ci.phone_no_mobile = '+49 173 678 54 69'
ci.person_id = p1.id
ci.save

# - - - - - - - - - - initial / root groups

GroupCategory.new do |gc|
  gc.label = 'General Responsible Entities'
  gc.seqno = 10
end.save!

GroupCategory.new do |gc|
  gc.label = 'Subsystems'
  gc.seqno = 20
end.save!

GroupCategory.new do |gc|
  gc.label = 'Electrification Subsystems'
  gc.seqno = 30
end.save!

GroupCategory.new do |gc|
  gc.label = 'Supplementary Correspondence Codes'
  gc.seqno = 80
end.save!

gc = GroupCategory.new
gc.label = 'Internal Administration'
gc.seqno = 90
gc.save

g = Group.new
g.code = 'ADMIN'
g.label = 'pmodbase Administration Group'
g.notes = 'for internal, tool administration use only'
g.seqno = 0
g.group_category_id = gc.id
g.active = true
g.participating = false
g.s_sender_code = false
g.s_receiver_code = false
g.standard = false
g.save

# - - - - - - - - - - initial / root user

r = Responsibility.new
r.description = 'System Administrator'
r.seqno = 1
r.group_id = g.id
r.person_id = p1.id
r.save

# - - - - - - - - - - inital accounts

a1 = Account.new
a1.name = 'admin'
a1.password = 'Pass-w0rd'
a1.person_id = p1.id
a1.keep_base_open = true
a1.save

a2 = Account.new
a2.name = 'tester1'
a2.password = 'A10ha!tester1'
a2.person_id = p2.id
a2.keep_base_open = false
a2.save

# - - - - - - - - - - permissions for root user

Feature.find_each do |f|
  next if f.no_user_access?
  Permission4Group.create do |ps|
    ps.feature_id = f.id
    ps.account_id = a1.id
    ps.group_id = 0
    ps.to_index = 1
    ps.to_create = 1
    ps.to_read = 1
    ps.to_update = 1
    ps.to_delete = 1
  end
end

# full access for DSR

p = Permission4Group.find_by( feature_id: FEATURE_ID_DSR_STATUS_RECORDS, account_id: a1.id )
p.to_read = 4
p.to_update = 4
p.save

# full acdess for CFR
p = Permission4Group.find_by( feature_id: FEATURE_ID_CFR_RECORDS, account_id: a1.id )
p.to_index = p.to_read = p.to_update = p.to_delete = CfrRecord::CONF_LEVEL_LABELS.size
p.save

# - - - - - - - - - - permissions for workflows

Permission4Flow.new do |p|
  p.feature_id = FEATURE_ID_RFC_STATUS_RECORDS
  p.account_id = a1.id
  p.workflow_id = 0
  p.label = 'Administrator'
  p.tasklist = '0,1,2,3,4,5,6,7'
end.save!

Permission4Flow.new do |p|
  p.feature_id = FEATURE_ID_RFC_STATUS_RECORDS
  p.account_id = a1.id
  p.workflow_id = 1
  p.label = 'Administrator'
  p.tasklist = '0,1,2,3,4,5,6,7,8,9'
end.save!

Permission4Flow.new do |p|
  p.feature_id = FEATURE_ID_RFC_STATUS_RECORDS
  p.account_id = a1.id
  p.workflow_id = 2
  p.label = 'Administrator'
  p.tasklist = '0,1,2,3'
end.save!

Permission4Flow.new do |p|
  p.feature_id = FEATURE_ID_DSR_STATUS_RECORDS
  p.account_id = a1.id
  p.workflow_id = 0
  p.label = 'Administrator'
  p.tasklist = '0,1,2,3,4,5,6,7,8,9,10'
end.save!

# - - - - - - - - - - DSR Progress Rates - one record per state

# PROGRESS_AT_SUBMISSION 60%
# =>
# Progress for Prepare/Submit Activity =
#   if pre-submission status  then document_progress*100/PROGRESS_AT_SUBMISSION
#   if post-submission status then 100%
# Progress for Review/Approve Activity =
#   if pre-submission status then 0%
#   if post-submission status then 
#     (document_progress-PROGRESS_AT_SUBMISSION)*100/(100-PROGRESS_AT_SUBMISSION)

DsrProgressRate.create( document_status:  0, document_progress:   0, prepare_progress:         0, approve_progress:         0 )
DsrProgressRate.create( document_status:  1, document_progress:  10, prepare_progress: 10*100/60, approve_progress:         0 )
DsrProgressRate.create( document_status:  2, document_progress:  50, prepare_progress: 50*100/60, approve_progress:         0 )
DsrProgressRate.create( document_status:  3, document_progress:  55, prepare_progress: 55*100/60, approve_progress:         0 )
DsrProgressRate.create( document_status:  4, document_progress:  60, prepare_progress: 60*100/60, approve_progress:         0 )
DsrProgressRate.create( document_status:  5, document_progress: 100, prepare_progress:       100, approve_progress:       100 )
DsrProgressRate.create( document_status:  6, document_progress:  80, prepare_progress:       100, approve_progress: 20*100/40 )
DsrProgressRate.create( document_status:  7, document_progress:  60, prepare_progress:       100, approve_progress:         0 )
DsrProgressRate.create( document_status:  8, document_progress: 100, prepare_progress:       100, approve_progress:       100 )
DsrProgressRate.create( document_status:  9, document_progress:  85, prepare_progress:       100, approve_progress: 25*100/40 )
DsrProgressRate.create( document_status: 10, document_progress:   0, prepare_progress:         0, approve_progress:         0 )
