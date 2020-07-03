class PullRequest < ApplicationRecord
  belongs_to :user
  belongs_to :repository

  validates :head, presence: true
  validates :base, presence: true

  validates :github_id, presence: true
  validates :title, presence: true
  validates :state, presence: true
  validates :owner, presence: true

  DEPLOY_DEV_BRANCH_LEGACY = 'dev'
  DEPLOY_DEV_BRANCH = 'develop'
  DEPLOY_QA_BRANCH = 'qa'
  DEPLOY_PROD_BRANCH = 'master'

  def self.deployment_branches?(base, head)
    (base == DEPLOY_QA_BRANCH || base == DEPLOY_PROD_BRANCH) && (head  == DEPLOY_DEV_BRANCH || head == DEPLOY_QA_BRANCH || head == DEPLOY_DEV_BRANCH_LEGACY)
  end

  state_machine :state, initial: :open do
    event :merge! do
      transition :open => :merged
    end

    event :cancel! do
      transition :open => :cancelled
    end
  end
end
