# This is the place to hold global constants:

  # name of the project / project site

  SITE_NAME = 'pmodbase'.freeze

  # number of columns on the base page used to list the tables to which the user
  # has access to (ultimately)

  NO_OF_COLUMNS_ON_BASE_PAGE = 3

  # maximum length of a feature code (note that the feature name is used in the
  # rails routing and must thus correspond with the rails MVC naming conventions!)

  MAX_LENGTH_OF_FEATURE_CODE = 10

  # width of labels in bootstrap columns

  BT_COL_WIDTH_LABELS = 3

  # CSV options: set here whatever CSV::DEFAULT_OPTIONS you need to override

  STD_CSV_OPTIONS = { col_sep: ';' }

  # maximum length of ...

  MAX_LENGTH_OF_ACCOUNT_NAME = 20
  MAX_LENGTH_OF_ADDRESS = 255
  MAX_LENGTH_OF_DEPARTMENT = 30
  MAX_LENGTH_OF_EMAIL_STRING = 255
  MAX_LENGTH_OF_INFORMATION_TYPE = 10
  MAX_LENGTH_OF_LOCATION_DETAIL = 30
  MAX_LENGTH_OF_PASSWORD = 72
  MAX_LENGTH_OF_PERSON_NAMES = 70
  MAX_LENGTH_OF_PHONE_NUMBER = 26
  MAX_LENGTH_OF_PROGRAMME_IDS = 20    # for P6 ids such as project ids, activity ids
  MAX_LENGTH_OF_RMS_ID = 20           # for DOORS requirement IDs
  MAX_LENGTH_OF_TERM = 60
  MAX_LENGTH_OF_DOC_ID = 50
  MAX_LENGTH_OF_DOC_VERSION = 10      # length of string for version information

	MAX_LENGTH_OF_LABEL = 50
  MAX_LENGTH_OF_NOTES = 50
	MAX_LENGTH_OF_CODE = 10
	MAX_LENGTH_OF_DESCRIPTION = 255
  MAX_LENGTH_OF_TITLE = 128
  MAX_LENGTH_OF_URI = 255
	
	DEFAULT_ROWS_TEXTAREA = 5
	DEFAULT_COLS_TEXTAREA = 50

  # The maxmimun number of tasks in a workflow is set below: This depends
  # on the size of the string in the database. If you need to increase the
  # number of tasks beyond 88, you need to change the field type for the 
  # Permission4Flows records from string to text ... Calculation:
  # - the first 10 tasks (0..9) will use up to 20 characters (1 digit + ,)
  # - the remaining 235 characters will be used in chunks of 3 (2 digits + ,)
  #   except for the last one which will only use 2
  #   i.e. 235 + 1 = 236 = 78

  MAX_NUMBER_OF_TASKS = 20
  MAX_LENGTH_OF_TASKS_STRING = 10 * 2 + ( MAX_NUMBER_OF_TASKS - 10 ) * 3 - 1

  # list of features - this must correspond to the .id field in the feature
  # item table!!! Any value change invalidates the current database!

  # FEATURE_ID_TEMPLATE = 0
  FEATURE_ID_FEATURE_CATEGORIES = 1
  FEATURE_ID_FEATURE_ITEMS = 2
  FEATURE_ID_PEOPLE = 3
  FEATURE_ID_CONTACT_INFOS = 4
  FEATURE_ID_ACCOUNTS_AND_PERMISSIONS = 5
  FEATURE_ID_DBSTATS = 6
  FEATURE_ID_ADDRESSES = 7
  FEATURE_ID_RESPONSIBILITIES = 8
  FEATURE_ID_GROUP_CATEGORIES = 9
  FEATURE_ID_GROUPS = 10
  FEATURE_ID_CONTACT_LISTS = 11
  FEATURE_ID_MY_CHANGE_REQUESTS = 12
  FEATURE_ID_DB_CHANGE_REQUESTS = 13
  FEATURE_ID_HOME_PAGE = 14
  FEATURE_ID_BASE_PAGE = 15
  FEATURE_ID_HELP_PAGES = 16
  FEATURE_ID_PROFILE = 17
  FEATURE_ID_PHASE_CODES = 18
  FEATURE_ID_SIEMENS_PHASES = 19
  FEATURE_ID_ABBREVIATIONS = 20
  FEATURE_ID_ABBR_SEARCH = 21
  FEATURE_ID_COUNTRY_NAMES = 22
  FEATURE_ID_STANDARDS_BODIES = 23
  FEATURE_ID_GLOSSARY = 24
  FEATURE_ID_REGION_NAMES = 25
  FEATURE_ID_HOLIDAYS = 26
  FEATURE_ID_SUBMISSION_GROUPS = 27
  FEATURE_ID_FEATURE_RESP = 28
  FEATURE_ID_UNIT_NAMES = 29
  FEATURE_ID_RFC_DOCUMENTS = 30
  FEATURE_ID_RFC_STATUS_RECORDS = 31
  FEATURE_ID_REFERENCES = 32
  FEATURE_ID_ACCESS_CONTROL = 33
  FEATURE_ID_WORKFLOW_PERMISSIONS = 34
  FEATURE_ID_ALL_TIA_LISTS = 35
  FEATURE_ID_MY_TIA_LISTS = 36
  FEATURE_ID_OUR_TIA_ITEMS = 37
  FEATURE_ID_MY_TIA_ITEMS = 38
  FEATURE_ID_OUR_TIA_MEMBERS = 39
  FEATURE_ID_DSR_STATUS_RECORDS = 40
  FEATURE_ID_DSR_SUBMISSIONS = 41
  FEATURE_ID_DSR_DOC_GROUPS = 42
  FEATURE_ID_DSR_PROGRESS_RATES = 43
  FEATURE_ID_CSR_STATUS_RECORDS = 44
  FEATURE_ID_ACTIVITIES = 45
  FEATURE_ID_WEB_LINKS = 46

  FEATURE_ID_MAX_PLUS_ONE = 47 # update this when inserting new features!