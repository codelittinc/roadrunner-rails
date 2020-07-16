# frozen_string_literal: true

FactoryBot.define do
  factory :repository do
    name { 'test-gh-notifications' }
    deploy_type { 'tag' }
    supports_deploy { true }

    before(:create) do |obj|
      obj.project ||= create(:project)
      obj.slack_repository_info ||= create(:slack_repository_info, repository: obj)
    end
  end
end
