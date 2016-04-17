# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160414101758) do

  create_table "a1_codes", force: :cascade do |t|
    t.string   "code",                      null: false
    t.string   "label",                     null: false
    t.boolean  "active",     default: true, null: false
    t.boolean  "master",     default: true, null: false
    t.string   "mapping"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "a1_codes", ["code"], name: "index_a1_codes_on_code"

  create_table "a2_codes", force: :cascade do |t|
    t.string   "code",                      null: false
    t.string   "label",                     null: false
    t.boolean  "active",     default: true, null: false
    t.boolean  "master",     default: true, null: false
    t.string   "mapping"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "a2_codes", ["code"], name: "index_a2_codes_on_code"

  create_table "a3_codes", force: :cascade do |t|
    t.string   "code",                      null: false
    t.string   "label",                     null: false
    t.boolean  "active",     default: true, null: false
    t.boolean  "master",     default: true, null: false
    t.string   "mapping"
    t.string   "desc"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "a3_codes", ["code"], name: "index_a3_codes_on_code"

  create_table "a4_codes", force: :cascade do |t|
    t.string   "code",                      null: false
    t.string   "label",                     null: false
    t.boolean  "active",     default: true, null: false
    t.boolean  "master",     default: true, null: false
    t.string   "mapping"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "a4_codes", ["code"], name: "index_a4_codes_on_code"

  create_table "a5_codes", force: :cascade do |t|
    t.string   "code",                      null: false
    t.string   "label",                     null: false
    t.boolean  "active",     default: true, null: false
    t.boolean  "master",     default: true, null: false
    t.string   "mapping"
    t.string   "desc"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "a5_codes", ["code"], name: "index_a5_codes_on_code"

  create_table "a6_codes", force: :cascade do |t|
    t.string   "code",                      null: false
    t.string   "label",                     null: false
    t.boolean  "active",     default: true, null: false
    t.boolean  "master",     default: true, null: false
    t.string   "mapping"
    t.string   "desc"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "a6_codes", ["code"], name: "index_a6_codes_on_code"

  create_table "a7_codes", force: :cascade do |t|
    t.string   "code",                      null: false
    t.string   "label",                     null: false
    t.boolean  "active",     default: true, null: false
    t.boolean  "master",     default: true, null: false
    t.string   "mapping"
    t.string   "desc"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "a7_codes", ["code"], name: "index_a7_codes_on_code"

  create_table "a8_codes", force: :cascade do |t|
    t.string   "code",                      null: false
    t.string   "label",                     null: false
    t.boolean  "active",     default: true, null: false
    t.boolean  "master",     default: true, null: false
    t.string   "mapping"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "a8_codes", ["code"], name: "index_a8_codes_on_code"

  create_table "a_document_logs", force: :cascade do |t|
    t.string   "a1_code",    limit: 10,  null: false
    t.string   "a2_code",    limit: 10,  null: false
    t.string   "a3_code",    limit: 10,  null: false
    t.string   "a4_code",    limit: 10,  null: false
    t.string   "a5_code",    limit: 10,  null: false
    t.string   "a6_code",    limit: 10,  null: false
    t.string   "a7_code",    limit: 10,  null: false
    t.string   "a8_code",    limit: 10,  null: false
    t.integer  "account_id",             null: false
    t.string   "title",      limit: 128
    t.string   "alt_doc_id", limit: 50
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "a_document_logs", ["id"], name: "index_a_document_logs_on_id"

  create_table "abbreviations", force: :cascade do |t|
    t.string   "code",        limit: 10,  null: false
    t.string   "sort_code",   limit: 10,  null: false
    t.string   "description", limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "abbreviations", ["sort_code"], name: "index_abbreviations_on_sort_code"

  create_table "accounts", force: :cascade do |t|
    t.string   "name",            limit: 20
    t.string   "password_digest"
    t.boolean  "active",                     default: true,  null: false
    t.boolean  "keep_base_open",             default: false, null: false
    t.integer  "person_id",                                  null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "addresses", force: :cascade do |t|
    t.string   "label",          limit: 50,  null: false
    t.string   "street_address", limit: 255
    t.string   "postal_address", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "addresses", ["label"], name: "index_addresses_on_label"

  create_table "contact_infos", force: :cascade do |t|
    t.string   "info_type",       limit: 10,              null: false
    t.string   "phone_no_fixed",  limit: 26, default: "", null: false
    t.string   "phone_no_mobile", limit: 26, default: "", null: false
    t.string   "department",      limit: 30, default: "", null: false
    t.string   "detail_location", limit: 30, default: "", null: false
    t.integer  "address_id"
    t.integer  "person_id",                               null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "country_names", force: :cascade do |t|
    t.string   "code",       limit: 10, null: false
    t.string   "label",      limit: 50, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "country_names", ["code"], name: "index_country_names_on_code"

  create_table "csr_status_records", force: :cascade do |t|
    t.integer  "correspondence_type",                            null: false
    t.integer  "transmission_type"
    t.string   "subject",                limit: 128
    t.integer  "sender_group_id"
    t.integer  "receiver_group_id"
    t.integer  "classification"
    t.date     "correspondence_date"
    t.date     "plan_reply_date"
    t.date     "actual_reply_date"
    t.integer  "reply_status_record_id"
    t.integer  "status",                             default: 0
    t.string   "project_doc_id",         limit: 50
    t.string   "sender_doc_id",          limit: 50
    t.string   "sender_reference",       limit: 50
    t.string   "notes",                  limit: 50
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "csr_status_records", ["correspondence_date"], name: "index_csr_status_records_on_correspondence_date"
  add_index "csr_status_records", ["correspondence_type"], name: "index_csr_status_records_on_correspondence_type"

  create_table "db_change_requests", force: :cascade do |t|
    t.integer  "requesting_account_id"
    t.integer  "responsible_account_id"
    t.integer  "feature_id"
    t.string   "detail",                 limit: 50
    t.string   "action",                 limit: 10
    t.integer  "status",                            default: 0
    t.string   "uri"
    t.text     "request_text"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "dcc_codes", force: :cascade do |t|
    t.string   "code",       limit: 10,                 null: false
    t.string   "label",      limit: 50,                 null: false
    t.boolean  "active",                default: true,  null: false
    t.boolean  "master",                default: true,  null: false
    t.boolean  "standard",              default: true,  null: false
    t.boolean  "heading",               default: false, null: false
    t.string   "note",       limit: 50
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "dcc_codes", ["code"], name: "index_dcc_codes_on_code"

  create_table "dsr_doc_groups", force: :cascade do |t|
    t.string   "code",       limit: 10
    t.string   "title",      limit: 128
    t.integer  "group_id",               null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "dsr_doc_groups", ["group_id"], name: "index_dsr_doc_groups_on_group_id"

  create_table "dsr_progress_rates", id: false, force: :cascade do |t|
    t.integer  "document_status",               null: false
    t.integer  "document_progress", default: 0
    t.integer  "prepare_progress",  default: 0
    t.integer  "approve_progress",  default: 0
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "dsr_progress_rates", ["document_status"], name: "index_dsr_progress_rates_on_document_status", unique: true

  create_table "dsr_status_records", force: :cascade do |t|
    t.string   "title",                     limit: 128
    t.integer  "document_status",                       default: 0
    t.integer  "document_status_b",                     default: 0
    t.string   "project_doc_id",            limit: 50
    t.integer  "sender_group_id",                                     null: false
    t.integer  "sender_group_b_id",                                   null: false
    t.string   "sender_doc_id",             limit: 50
    t.integer  "receiver_group_id"
    t.string   "receiver_doc_id",           limit: 50
    t.integer  "sub_purpose",                           default: 0
    t.integer  "sub_frequency",                         default: 0
    t.integer  "quantity",                              default: 1
    t.integer  "quantity_b",                            default: 0
    t.decimal  "weight",                                default: 1.0
    t.decimal  "weight_b",                              default: 0.0
    t.integer  "dsr_doc_group_id"
    t.integer  "submission_group_id"
    t.integer  "submission_group_b_id"
    t.integer  "prep_activity_id"
    t.integer  "subm_activity_id"
    t.integer  "dsr_current_submission_id"
    t.date     "plnd_prep_start"
    t.date     "plnd_prep_start_b"
    t.date     "estm_prep_start"
    t.date     "actl_prep_start"
    t.date     "plnd_submission_1"
    t.date     "plnd_submission_b"
    t.date     "estm_submission"
    t.date     "actl_submission_1"
    t.date     "next_submission"
    t.date     "plnd_completion"
    t.date     "plnd_completion_b"
    t.date     "estm_completion"
    t.date     "actl_completion"
    t.datetime "baseline_date"
    t.string   "notes",                     limit: 50
    t.integer  "current_status",                        default: 0,   null: false
    t.integer  "current_status_b",                      default: 0,   null: false
    t.integer  "current_task",                          default: 0,   null: false
    t.integer  "current_task_b",                        default: 0,   null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "dsr_status_records", ["dsr_current_submission_id"], name: "index_dsr_status_records_on_dsr_current_submission_id"
  add_index "dsr_status_records", ["dsr_doc_group_id"], name: "index_dsr_status_records_on_dsr_doc_group_id"
  add_index "dsr_status_records", ["prep_activity_id"], name: "index_dsr_status_records_on_prep_activity_id"
  add_index "dsr_status_records", ["subm_activity_id"], name: "index_dsr_status_records_on_subm_activity_id"
  add_index "dsr_status_records", ["submission_group_b_id"], name: "index_dsr_status_records_on_submission_group_b_id"
  add_index "dsr_status_records", ["submission_group_id"], name: "index_dsr_status_records_on_submission_group_id"

  create_table "dsr_submissions", force: :cascade do |t|
    t.integer  "dsr_status_record_id",                              null: false
    t.integer  "submission_no",                         default: 1, null: false
    t.string   "sender_doc_id_version",      limit: 10
    t.string   "receiver_doc_id_version",    limit: 10
    t.string   "project_doc_id_version",     limit: 10
    t.string   "submission_receiver_doc_id", limit: 50
    t.string   "submission_project_doc_id",  limit: 50
    t.string   "response_sender_doc_id",     limit: 50
    t.string   "response_project_doc_id",    limit: 50
    t.date     "plnd_submission"
    t.date     "actl_submission"
    t.date     "xpcd_response"
    t.date     "actl_response"
    t.integer  "response_status"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "dsr_submissions", ["dsr_status_record_id", "submission_no"], name: "dsr_submissions_key2", unique: true

  create_table "feature_categories", force: :cascade do |t|
    t.string   "label",      default: "", null: false
    t.integer  "seqno",      default: 0,  null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "features", force: :cascade do |t|
    t.string   "code",                limit: 10
    t.string   "label",               limit: 50
    t.integer  "seqno",                          default: 0
    t.integer  "access_level",                   default: 0
    t.integer  "control_level",                  default: 0
    t.integer  "no_workflows",                   default: 0
    t.integer  "feature_category_id",                        null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "function_codes", force: :cascade do |t|
    t.string   "code",       limit: 10,                 null: false
    t.string   "label",      limit: 50,                 null: false
    t.boolean  "active",                default: true,  null: false
    t.boolean  "master",                default: true,  null: false
    t.boolean  "standard",              default: true,  null: false
    t.boolean  "heading",               default: false, null: false
    t.string   "note",       limit: 50
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "function_codes", ["code"], name: "index_function_codes_on_code"

  create_table "glossary_items", force: :cascade do |t|
    t.string   "term",         limit: 60, null: false
    t.string   "code",         limit: 10
    t.text     "description"
    t.integer  "reference_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "glossary_items", ["code"], name: "index_glossary_items_on_code"
  add_index "glossary_items", ["term"], name: "index_glossary_items_on_term"

  create_table "group_categories", force: :cascade do |t|
    t.string   "label",      default: "", null: false
    t.integer  "seqno",      default: 0,  null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "group_categories", ["seqno", "label"], name: "group_categories_key2"

  create_table "groups", force: :cascade do |t|
    t.string   "code",              limit: 10, default: "",   null: false
    t.string   "label",             limit: 50, default: "",   null: false
    t.string   "notes",             limit: 50
    t.integer  "seqno",                        default: 0
    t.integer  "group_category_id",                           null: false
    t.integer  "sub_group_of_id"
    t.boolean  "participating",                default: true
    t.boolean  "s_sender_code",                default: true
    t.boolean  "s_receiver_code",              default: true
    t.boolean  "active",                       default: true
    t.boolean  "standard",                     default: true
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "groups", ["code"], name: "index_groups_on_code"
  add_index "groups", ["sub_group_of_id"], name: "index_groups_on_sub_group_of_id"

  create_table "hashtags", force: :cascade do |t|
    t.string   "code"
    t.string   "label"
    t.integer  "feature_id"
    t.string   "sort_code"
    t.integer  "seqno",      default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "hashtags", ["feature_id", "code"], name: "index_hashtags_on_feature_id_and_code", unique: true

  create_table "holidays", force: :cascade do |t|
    t.date     "date_from",                               null: false
    t.date     "date_until",                              null: false
    t.integer  "year_period",                             null: false
    t.integer  "country_name_id",                         null: false
    t.integer  "region_name_id"
    t.string   "description",     limit: 255
    t.integer  "work",                        default: 0, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "holidays", ["country_name_id"], name: "index_holidays_on_country_name_id"
  add_index "holidays", ["date_from"], name: "index_holidays_on_date_from"
  add_index "holidays", ["year_period"], name: "index_holidays_on_year_period"

  create_table "location_codes", force: :cascade do |t|
    t.string   "code",         limit: 10,             null: false
    t.string   "label",        limit: 50,             null: false
    t.integer  "loc_type",                default: 2, null: false
    t.integer  "center_point"
    t.integer  "start_point"
    t.integer  "end_point"
    t.integer  "length"
    t.string   "note",         limit: 50
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "location_codes", ["code"], name: "index_location_codes_on_code"

  create_table "network_lines", force: :cascade do |t|
    t.string   "code",                         null: false
    t.string   "label",                        null: false
    t.integer  "seqno",            default: 0, null: false
    t.string   "note"
    t.integer  "location_code_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "network_stations", force: :cascade do |t|
    t.string   "code",                       null: false
    t.string   "alt_code"
    t.string   "curr_name"
    t.string   "prev_name"
    t.boolean  "transfer",   default: false, null: false
    t.string   "note"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "network_stops", force: :cascade do |t|
    t.integer  "network_station_id", null: false
    t.integer  "network_line_id",    null: false
    t.integer  "location_code_id"
    t.integer  "stop_no"
    t.string   "code"
    t.string   "note"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "network_stops", ["network_line_id", "stop_no"], name: "index_network_stops_on_network_line_id_and_stop_no"
  add_index "network_stops", ["network_line_id"], name: "index_network_stops_on_network_line_id"
  add_index "network_stops", ["network_station_id"], name: "index_network_stops_on_network_station_id"

  create_table "pcp_categories", force: :cascade do |t|
    t.integer  "c_group_id",  null: false
    t.integer  "p_group_id",  null: false
    t.integer  "c_owner_id",  null: false
    t.integer  "p_owner_id",  null: false
    t.integer  "c_deputy_id"
    t.integer  "p_deputy_id"
    t.string   "label",       null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "pcp_categories", ["c_deputy_id"], name: "index_pcp_categories_on_c_deputy_id"
  add_index "pcp_categories", ["c_group_id"], name: "index_pcp_categories_on_c_group_id"
  add_index "pcp_categories", ["c_owner_id"], name: "index_pcp_categories_on_c_owner_id"
  add_index "pcp_categories", ["p_deputy_id"], name: "index_pcp_categories_on_p_deputy_id"
  add_index "pcp_categories", ["p_group_id"], name: "index_pcp_categories_on_p_group_id"
  add_index "pcp_categories", ["p_owner_id"], name: "index_pcp_categories_on_p_owner_id"

  create_table "pcp_steps", force: :cascade do |t|
    t.integer  "pcp_subject_id",                         null: false
    t.integer  "step_no",                    default: 0, null: false
    t.string   "subject_version", limit: 10
    t.string   "note",            limit: 50
    t.date     "subject_date"
    t.date     "due_date"
    t.integer  "subject_status",             default: 0
    t.integer  "assessment",                 default: 0
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "pcp_steps", ["pcp_subject_id", "step_no"], name: "pcp_steps_index", unique: true
  add_index "pcp_steps", ["pcp_subject_id"], name: "index_pcp_steps_on_pcp_subject_id"

  create_table "pcp_subjects", force: :cascade do |t|
    t.integer  "pcp_category_id",                             null: false
    t.integer  "c_group_id",                                  null: false
    t.integer  "p_group_id",                                  null: false
    t.integer  "c_owner_id",                                  null: false
    t.integer  "c_deputy_id"
    t.integer  "p_owner_id",                                  null: false
    t.integer  "p_deputy_id"
    t.string   "desc",            limit: 255
    t.string   "note",            limit: 50
    t.string   "project_doc_id",  limit: 50
    t.string   "report_doc_id",   limit: 50
    t.boolean  "archived",                    default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "pcp_subjects", ["archived", "pcp_category_id", "id"], name: "active_pcp_subjects"
  add_index "pcp_subjects", ["c_deputy_id"], name: "index_pcp_subjects_on_c_deputy_id"
  add_index "pcp_subjects", ["c_group_id"], name: "index_pcp_subjects_on_c_group_id"
  add_index "pcp_subjects", ["c_owner_id"], name: "index_pcp_subjects_on_c_owner_id"
  add_index "pcp_subjects", ["p_deputy_id"], name: "index_pcp_subjects_on_p_deputy_id"
  add_index "pcp_subjects", ["p_group_id"], name: "index_pcp_subjects_on_p_group_id"
  add_index "pcp_subjects", ["p_owner_id"], name: "index_pcp_subjects_on_p_owner_id"
  add_index "pcp_subjects", ["pcp_category_id"], name: "index_pcp_subjects_on_pcp_category_id"

  create_table "people", force: :cascade do |t|
    t.string   "formal_name",   limit: 70,  default: "",   null: false
    t.string   "informal_name", limit: 70,  default: "",   null: false
    t.string   "email",         limit: 255, default: "",   null: false
    t.boolean  "involved",                  default: true, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "permission4_flows", force: :cascade do |t|
    t.integer  "account_id",  null: false
    t.integer  "feature_id",  null: false
    t.integer  "workflow_id", null: false
    t.string   "label"
    t.string   "tasklist"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "permission4_flows", ["feature_id", "workflow_id", "account_id"], name: "rfc_index", unique: true

  create_table "permission4_groups", force: :cascade do |t|
    t.integer  "account_id",             null: false
    t.integer  "feature_id",             null: false
    t.integer  "group_id",               null: false
    t.integer  "to_index",   default: 0, null: false
    t.integer  "to_create",  default: 0, null: false
    t.integer  "to_read",    default: 0, null: false
    t.integer  "to_update",  default: 0, null: false
    t.integer  "to_delete",  default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "permission4_groups", ["account_id", "feature_id", "group_id"], name: "afg_index", unique: true

  create_table "phase_codes", force: :cascade do |t|
    t.string   "code",             limit: 10,             null: false
    t.string   "label",            limit: 50,             null: false
    t.string   "acro",             limit: 10
    t.integer  "siemens_phase_id",                        null: false
    t.integer  "level",                       default: 0
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "product_codes", force: :cascade do |t|
    t.string   "code",       limit: 10,                 null: false
    t.string   "label",      limit: 50,                 null: false
    t.boolean  "active",                default: true,  null: false
    t.boolean  "master",                default: true,  null: false
    t.boolean  "standard",              default: true,  null: false
    t.boolean  "heading",               default: false, null: false
    t.string   "note",       limit: 50
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "product_codes", ["code"], name: "index_product_codes_on_code"

  create_table "programme_activities", force: :cascade do |t|
    t.string   "project_id"
    t.string   "activity_id"
    t.string   "activity_label"
    t.date     "start_date"
    t.date     "finish_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "references", force: :cascade do |t|
    t.string   "code",           limit: 10,  null: false
    t.string   "description",    limit: 255
    t.string   "project_doc_id", limit: 50
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "references", ["code"], name: "index_references_on_code"

  create_table "region_names", force: :cascade do |t|
    t.integer  "country_name_id",            null: false
    t.string   "code",            limit: 10, null: false
    t.string   "label",           limit: 50, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "region_names", ["country_name_id", "code"], name: "cr_index", unique: true

  create_table "responsibilities", force: :cascade do |t|
    t.string   "description", limit: 255, default: "", null: false
    t.integer  "seqno",                   default: 99
    t.integer  "group_id",                             null: false
    t.integer  "person_id",               default: 0,  null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "rfc_documents", force: :cascade do |t|
    t.integer  "rfc_status_record_id",             null: false
    t.integer  "version",              default: 0, null: false
    t.text     "question"
    t.text     "answer"
    t.text     "note"
    t.integer  "account_id",                       null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "rfc_documents", ["rfc_status_record_id", "version"], name: "main_key", unique: true

  create_table "rfc_status_records", force: :cascade do |t|
    t.integer  "rfc_type",                           default: 0, null: false
    t.string   "title",                  limit: 128
    t.integer  "asking_group_id"
    t.integer  "answering_group_id"
    t.string   "project_doc_id",         limit: 50
    t.string   "project_rms_id",         limit: 20
    t.string   "asking_group_doc_id",    limit: 50
    t.string   "answering_group_doc_id", limit: 50
    t.integer  "current_status",                     default: 0, null: false
    t.integer  "current_task",                       default: 0, null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "s_document_logs", force: :cascade do |t|
    t.integer  "group_id",                   null: false
    t.integer  "account_id",                 null: false
    t.string   "receiver_group", limit: 10
    t.string   "function_code",  limit: 10
    t.string   "service_code",   limit: 10
    t.string   "product_code",   limit: 10
    t.string   "location_code",  limit: 10
    t.string   "phase_code",     limit: 10
    t.string   "dcc_code",       limit: 10
    t.string   "revision_code",  limit: 10
    t.date     "author_date"
    t.string   "title",          limit: 128
    t.string   "siemens_doc_id", limit: 100
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "s_document_logs", ["id"], name: "index_s_document_logs_on_id"

  create_table "service_codes", force: :cascade do |t|
    t.string   "code",       limit: 10,                 null: false
    t.string   "label",      limit: 50,                 null: false
    t.boolean  "active",                default: true,  null: false
    t.boolean  "master",                default: true,  null: false
    t.boolean  "standard",              default: true,  null: false
    t.boolean  "heading",               default: false, null: false
    t.string   "note",       limit: 50
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "service_codes", ["code"], name: "index_service_codes_on_code"

  create_table "siemens_phases", force: :cascade do |t|
    t.string   "code",       limit: 10, null: false
    t.string   "label_p",    limit: 50
    t.string   "label_m",    limit: 50
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "standards_bodies", force: :cascade do |t|
    t.string   "code",        limit: 10,  null: false
    t.string   "description", limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "standards_bodies", ["code"], name: "index_standards_bodies_on_code"

  create_table "submission_groups", force: :cascade do |t|
    t.string   "code",       limit: 10, null: false
    t.string   "label",      limit: 50
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "submission_groups", ["code"], name: "index_submission_groups_on_code"

  create_table "tia_item_deltas", force: :cascade do |t|
    t.integer  "tia_item_id", null: false
    t.text     "delta_hash"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "tia_item_deltas", ["tia_item_id", "created_at"], name: "index_tia_item_deltas_on_tia_item_id_and_created_at"
  add_index "tia_item_deltas", ["tia_item_id"], name: "index_tia_item_deltas_on_tia_item_id"

  create_table "tia_items", force: :cascade do |t|
    t.integer  "tia_list_id",                 null: false
    t.integer  "account_id"
    t.integer  "seqno",       default: 1
    t.string   "description",                 null: false
    t.string   "comment"
    t.integer  "prio",        default: 0
    t.integer  "status",      default: 0
    t.date     "due_date"
    t.boolean  "archived",    default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "tia_items", ["account_id"], name: "index_tia_items_on_account_id"
  add_index "tia_items", ["tia_list_id", "seqno"], name: "tia_list_items_index", unique: true

  create_table "tia_lists", force: :cascade do |t|
    t.integer  "owner_account_id",  null: false
    t.integer  "deputy_account_id"
    t.string   "code"
    t.string   "label"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "tia_lists", ["deputy_account_id"], name: "index_tia_lists_on_deputy_account_id"
  add_index "tia_lists", ["owner_account_id"], name: "index_tia_lists_on_owner_account_id"

  create_table "tia_members", force: :cascade do |t|
    t.integer  "account_id",                  null: false
    t.integer  "tia_list_id",                 null: false
    t.boolean  "to_access",   default: true,  null: false
    t.boolean  "to_update",   default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "tia_members", ["account_id"], name: "index_tia_members_on_account_id"
  add_index "tia_members", ["tia_list_id"], name: "index_tia_members_on_tia_list_id"

  create_table "unit_names", force: :cascade do |t|
    t.string   "code",       limit: 10, null: false
    t.string   "label",      limit: 50, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "unit_names", ["code"], name: "index_unit_names_on_code"

  create_table "web_links", force: :cascade do |t|
    t.string   "label",      default: "", null: false
    t.text     "hyperlink"
    t.integer  "seqno",      default: 0,  null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "web_links", ["seqno", "label"], name: "web_links_key2"

end
