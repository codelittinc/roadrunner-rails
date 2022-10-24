# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_10_23_180544) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applications", force: :cascade do |t|
    t.string "environment"
    t.bigint "repository_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repository_id"], name: "index_applications_on_repository_id"
  end

  create_table "azure_pull_requests", force: :cascade do |t|
    t.string "source_control_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "branches", force: :cascade do |t|
    t.string "name"
    t.bigint "repository_id", null: false
    t.bigint "pull_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pull_request_id"], name: "index_branches_on_pull_request_id", unique: true
    t.index ["repository_id"], name: "index_branches_on_repository_id"
  end

  create_table "check_runs", force: :cascade do |t|
    t.string "state"
    t.string "commit_sha"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "branch_id"
    t.index ["branch_id"], name: "index_check_runs_on_branch_id"
  end

  create_table "commit_releases", force: :cascade do |t|
    t.bigint "commit_id"
    t.bigint "release_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commit_id"], name: "index_commit_releases_on_commit_id"
    t.index ["release_id"], name: "index_commit_releases_on_release_id"
  end

  create_table "commits", force: :cascade do |t|
    t.string "sha"
    t.string "message"
    t.string "author_name"
    t.string "author_email"
    t.bigint "pull_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pull_request_id"], name: "index_commits_on_pull_request_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "slack_api_key"
    t.string "github_api_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sentry_name"
  end

  create_table "external_identifiers", force: :cascade do |t|
    t.string "text"
    t.bigint "application_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_external_identifiers_on_application_id"
  end

  create_table "flow_requests", force: :cascade do |t|
    t.string "json"
    t.string "flow_name"
    t.boolean "executed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "error_message"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "github_installations", force: :cascade do |t|
    t.string "installation_id"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["organization_id"], name: "index_github_installations_on_organization_id"
  end

  create_table "github_pull_requests", force: :cascade do |t|
    t.string "source_control_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "issues", force: :cascade do |t|
    t.string "story_type"
    t.string "state"
    t.string "title"
    t.decimal "story_points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sprint_id"
    t.bigint "user_id"
    t.string "tags"
    t.index ["sprint_id"], name: "index_issues_on_sprint_id"
    t.index ["user_id"], name: "index_issues_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "notifications_id"
    t.string "name"
    t.string "notifications_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.bigint "customer_id"
    t.index ["customer_id"], name: "index_projects_on_customer_id"
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "pull_request_changes", force: :cascade do |t|
    t.bigint "pull_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pull_request_id"], name: "index_pull_request_changes_on_pull_request_id"
  end

  create_table "pull_request_reviews", force: :cascade do |t|
    t.string "state"
    t.string "username"
    t.bigint "pull_request_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pull_request_id"], name: "index_pull_request_reviews_on_pull_request_id"
  end

  create_table "pull_requests", force: :cascade do |t|
    t.string "head"
    t.string "base"
    t.string "title"
    t.string "description"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "repository_id"
    t.bigint "user_id"
    t.string "ci_state"
    t.string "source_type"
    t.bigint "source_id"
    t.datetime "merged_at", precision: nil
    t.index ["repository_id"], name: "index_pull_requests_on_repository_id"
    t.index ["source_type", "source_id"], name: "index_pull_requests_on_source"
    t.index ["user_id"], name: "index_pull_requests_on_user_id"
  end

  create_table "releases", force: :cascade do |t|
    t.string "version"
    t.bigint "application_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "deploy_status"
    t.index ["application_id"], name: "index_releases_on_application_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_id"
    t.string "deploy_type"
    t.boolean "supports_deploy"
    t.string "name"
    t.string "jira_project"
    t.string "owner"
    t.string "friendly_name"
    t.string "source_control_type"
    t.bigint "organization_id"
    t.index ["friendly_name"], name: "index_repositories_on_friendly_name", unique: true
    t.index ["organization_id"], name: "index_repositories_on_organization_id"
    t.index ["project_id"], name: "index_repositories_on_project_id"
  end

  create_table "server_incident_instances", force: :cascade do |t|
    t.bigint "server_incident_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_incident_id"], name: "index_server_incident_instances_on_server_incident_id"
  end

  create_table "server_incident_types", force: :cascade do |t|
    t.string "name"
    t.string "regex_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "server_incidents", force: :cascade do |t|
    t.string "message"
    t.bigint "server_status_check_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
    t.bigint "slack_message_id"
    t.integer "application_id"
    t.index ["server_status_check_id"], name: "index_server_incidents_on_server_status_check_id"
    t.index ["slack_message_id"], name: "index_server_incidents_on_slack_message_id"
  end

  create_table "server_status_checks", force: :cascade do |t|
    t.integer "code"
    t.bigint "server_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["server_id"], name: "index_server_status_checks_on_server_id"
  end

  create_table "servers", force: :cascade do |t|
    t.string "link"
    t.boolean "supports_health_check"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.string "environment"
    t.bigint "application_id"
    t.index ["application_id"], name: "index_servers_on_application_id"
  end

  create_table "slack_messages", force: :cascade do |t|
    t.string "ts"
    t.bigint "pull_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "text"
    t.index ["pull_request_id"], name: "index_slack_messages_on_pull_request_id"
  end

  create_table "slack_repository_infos", force: :cascade do |t|
    t.string "deploy_channel"
    t.bigint "repository_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dev_channel"
    t.string "dev_group"
    t.string "feed_channel"
    t.index ["repository_id"], name: "index_slack_repository_infos_on_repository_id"
  end

  create_table "sprints", force: :cascade do |t|
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.string "name"
    t.string "time_frame"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "team"
    t.bigint "customer_id"
    t.index ["customer_id"], name: "index_sprints_on_customer_id"
  end

  create_table "user_admins", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "github"
    t.string "jira"
    t.string "slack"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "azure"
    t.string "azure_devops_issues"
    t.bigint "customer_id"
    t.string "name"
    t.boolean "active", default: true
    t.index ["customer_id"], name: "index_users_on_customer_id"
  end

  add_foreign_key "applications", "repositories"
  add_foreign_key "branches", "pull_requests"
  add_foreign_key "branches", "repositories"
  add_foreign_key "check_runs", "branches"
  add_foreign_key "issues", "sprints"
  add_foreign_key "issues", "users"
  add_foreign_key "projects", "customers"
  add_foreign_key "pull_request_changes", "pull_requests"
  add_foreign_key "pull_request_reviews", "pull_requests"
  add_foreign_key "pull_requests", "repositories"
  add_foreign_key "pull_requests", "users"
  add_foreign_key "releases", "applications"
  add_foreign_key "repositories", "organizations"
  add_foreign_key "server_incident_instances", "server_incidents"
  add_foreign_key "servers", "applications"
  add_foreign_key "slack_repository_infos", "repositories"
  add_foreign_key "sprints", "customers"
  add_foreign_key "users", "customers"
end
