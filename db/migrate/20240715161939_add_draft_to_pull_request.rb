class AddDraftToPullRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :pull_requests, :draft, :boolean, default: false, null: false
  end
end
