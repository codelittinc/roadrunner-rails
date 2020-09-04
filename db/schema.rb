# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_04_192423) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "check_runs", force: :cascade do |t|
    t.string "state"
    t.string "commit_sha"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "commits", force: :cascade do |t|
    t.string "sha"
    t.string "message"
    t.string "author_name"
    t.string "author_email"
    t.bigint "pull_request_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pull_request_id"], name: "index_commits_on_pull_request_id"
  end

  create_table "flow_requests", force: :cascade do |t|
    t.string "json"
    t.string "flow_name"
    t.boolean "executed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  create_table "github_authentications", force: :cascade do |t|
    t.string "access_token"
    t.string "refresh_token"
    t.integer "refresh_token_expires_in"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "slug"
    t.index ["slug"], name: "index_projects_on_slug", unique: true
  end

  create_table "pull_request_changes", force: :cascade do |t|
    t.bigint "pull_request_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pull_request_id"], name: "index_pull_request_changes_on_pull_request_id"
  end

  create_table "pull_request_reviews", force: :cascade do |t|
    t.string "state"
    t.string "username"
    t.bigint "pull_request_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pull_request_id"], name: "index_pull_request_reviews_on_pull_request_id"
  end

  create_table "pull_requests", force: :cascade do |t|
    t.string "head"
    t.string "base"
    t.integer "github_id"
    t.string "title"
    t.string "description"
    t.string "state"
    t.string "owner"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "repository_id"
    t.bigint "user_id"
    t.string "ci_state"
    t.index ["github_id", "repository_id"], name: "index_pull_requests_on_github_id_and_repository_id", unique: true
    t.index ["repository_id"], name: "index_pull_requests_on_repository_id"
    t.index ["user_id"], name: "index_pull_requests_on_user_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "project_id"
    t.string "deploy_type"
    t.boolean "supports_deploy"
    t.string "name"
    t.string "jira_project"
    t.string "alias"
    t.string "owner"
    t.index ["project_id"], name: "index_repositories_on_project_id"
  end

  create_table "server_incidents", force: :cascade do |t|
    t.string "message"
    t.bigint "server_id"
    t.bigint "server_status_check_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["server_id"], name: "index_server_incidents_on_server_id"
    t.index ["server_status_check_id"], name: "index_server_incidents_on_server_status_check_id"
  end

  create_table "server_status_checks", force: :cascade do |t|
    t.integer "code"
    t.bigint "server_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["server_id"], name: "index_server_status_checks_on_server_id"
  end

  create_table "servers", force: :cascade do |t|
    t.string "link"
    t.boolean "supports_health_check"
    t.bigint "repository_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "external_identifier"
    t.boolean "active", default: true
    t.string "environment"
    t.string "name"
    t.index ["repository_id"], name: "index_servers_on_repository_id"
  end

  create_table "slack_messages", force: :cascade do |t|
    t.string "ts"
    t.bigint "pull_request_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "text"
    t.index ["pull_request_id"], name: "index_slack_messages_on_pull_request_id"
  end

  create_table "slack_repository_infos", force: :cascade do |t|
    t.string "deploy_channel"
    t.bigint "repository_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "dev_channel"
    t.string "dev_group"
    t.string "feed_channel"
    t.index ["repository_id"], name: "index_slack_repository_infos_on_repository_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "github"
    t.string "jira"
    t.string "slack"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "pull_request_changes", "pull_requests"
  add_foreign_key "pull_request_reviews", "pull_requests"
  add_foreign_key "pull_requests", "repositories"
  add_foreign_key "pull_requests", "users"
  add_foreign_key "slack_repository_infos", "repositories"
end
