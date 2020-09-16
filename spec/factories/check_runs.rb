# frozen_string_literal: true

# == Schema Information
#
# Table name: check_runs
#
#  id         :bigint           not null, primary key
#  state      :string
#  commit_sha :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  branch_id  :bigint
#
FactoryBot.define do
  factory :check_run do
    state { 'success' }
    commit_sha { '1' }
  end
end
