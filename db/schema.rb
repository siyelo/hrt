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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120710122400) do

  create_table "activities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "type"
    t.text     "other_beneficiaries"
    t.integer  "data_response_id"
    t.integer  "activity_id"
    t.integer  "project_id"
    t.integer  "user_id"
    t.boolean  "planned_for_gor_q1"
    t.boolean  "planned_for_gor_q2"
    t.boolean  "planned_for_gor_q3"
    t.boolean  "planned_for_gor_q4"
    t.integer  "previous_id"
  end

  add_index "activities", ["activity_id"], :name => "index_activities_on_activity_id"
  add_index "activities", ["data_response_id"], :name => "index_activities_on_data_response_id"
  add_index "activities", ["type"], :name => "index_activities_on_type"

  create_table "activities_beneficiaries", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "beneficiary_id"
  end

  create_table "activities_locations", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "location_id"
  end

  create_table "activities_projects", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "activity_id"
  end

  create_table "code_splits", :force => true do |t|
    t.integer  "activity_id"
    t.integer  "code_id"
    t.string   "type"
    t.decimal  "percentage"
    t.decimal  "cached_amount",   :default => 0.0
    t.decimal  "sum_of_children", :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "code_splits", ["activity_id", "code_id", "type"], :name => "index_code_assignments_on_activity_id_and_code_id_and_type"
  add_index "code_splits", ["code_id"], :name => "index_code_assignments_on_code_id"

  create_table "codes", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "short_display"
    t.string   "long_display"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "external_id"
    t.string   "hssp2_stratprog_val"
    t.string   "hssp2_stratobj_val"
    t.string   "official_name"
    t.string   "sub_account"
    t.string   "nha_code"
    t.string   "nasa_code"
  end

  create_table "comments", :force => true do |t|
    t.text     "comment",          :default => ""
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.boolean  "removed",          :default => false
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "currencies", :force => true do |t|
    t.float    "rate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "from"
    t.string   "to"
  end

  create_table "data_elements", :force => true do |t|
    t.integer "data_response_id"
    t.integer "data_elementable_id"
    t.string  "data_elementable_type"
  end

  add_index "data_elements", ["data_elementable_id"], :name => "index_data_elements_on_data_elementable_id"
  add_index "data_elements", ["data_elementable_type"], :name => "index_data_elements_on_data_elementable_type"
  add_index "data_elements", ["data_response_id"], :name => "index_data_elements_on_data_response_id"

  create_table "data_requests", :force => true do |t|
    t.integer  "organization_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
  end

  create_table "data_responses", :force => true do |t|
    t.integer  "data_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.string   "state"
    t.integer  "projects_count",  :default => 0
    t.integer  "previous_id"
  end

  add_index "data_responses", ["data_request_id"], :name => "index_data_responses_on_data_request_id"
  add_index "data_responses", ["organization_id"], :name => "index_data_responses_on_organization_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "documents", :force => true do |t|
    t.string   "title"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "visibility"
    t.text     "description"
  end

  create_table "field_helps", :force => true do |t|
    t.string   "attribute_name"
    t.string   "short"
    t.text     "long"
    t.integer  "model_help_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "funding_flows", :force => true do |t|
    t.integer  "organization_id_from"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "budget"
    t.text     "organization_text"
    t.integer  "self_provider_flag",   :default => 0
    t.decimal  "spend"
    t.decimal  "spend_q4_prev"
    t.decimal  "budget_q4_prev"
    t.integer  "project_from_id"
    t.integer  "previous_id"
  end

  add_index "funding_flows", ["project_id"], :name => "index_funding_flows_on_project_id"
  add_index "funding_flows", ["self_provider_flag"], :name => "index_funding_flows_on_self_provider_flag"

  create_table "help_requests", :force => true do |t|
    t.string   "email"
    t.text     "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "implementer_splits", :force => true do |t|
    t.integer  "activity_id"
    t.integer  "organization_id"
    t.decimal  "spend"
    t.decimal  "budget"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "double_count"
    t.integer  "previous_id"
  end

  create_table "locations_organizations", :id => false, :force => true do |t|
    t.integer "location_id"
    t.integer "organization_id"
  end

  create_table "locations_projects", :id => false, :force => true do |t|
    t.integer "location_id"
    t.integer "project_id"
  end

  create_table "model_helps", :force => true do |t|
    t.string   "model_name"
    t.string   "short"
    t.text     "long"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "comments_count", :default => 0
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "raw_type"
    t.string   "fosaid"
    t.integer  "users_count",                      :default => 0
    t.string   "currency"
    t.string   "contact_name"
    t.string   "contact_position"
    t.string   "contact_phone_number"
    t.string   "contact_main_office_phone_number"
    t.string   "contact_office_location"
    t.string   "implementer_type"
    t.string   "funder_type"
    t.integer  "fy_start_month"
  end

  create_table "organizations_managers", :id => false, :force => true do |t|
    t.integer "organization_id"
    t.integer "user_id"
  end

  create_table "outputs", :force => true do |t|
    t.integer  "activity_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "currency"
    t.integer  "data_response_id"
    t.string   "budget_type"
    t.integer  "previous_id"
  end

  add_index "projects", ["data_response_id"], :name => "index_projects_on_data_response_id"

  create_table "reports", :force => true do |t|
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "data_request_id"
  end

  create_table "response_state_logs", :force => true do |t|
    t.integer  "data_response_id"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "targets", :force => true do |t|
    t.integer  "activity_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "roles_mask"
    t.integer  "organization_id"
    t.text     "text_for_organization"
    t.string   "full_name"
    t.boolean  "tips_shown",             :default => true
    t.string   "invite_token"
    t.boolean  "active",                 :default => false
    t.integer  "location_id"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "workplan_file_name"
    t.string   "workplan_content_type"
    t.integer  "workplan_file_size"
    t.datetime "workplan_updated_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
