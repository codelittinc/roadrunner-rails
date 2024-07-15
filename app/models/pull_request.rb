# frozen_string_literal: true

# == Schema Information
#
# Table name: pull_requests
#
#  id                :bigint           not null, primary key
#  base              :string
#  ci_state          :string
#  description       :string
#  head              :string
#  merged_at         :datetime
#  source_type       :string
#  state             :string
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  backstage_user_id :integer
#  repository_id     :bigint
#  source_id         :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_pull_requests_on_repository_id  (repository_id)
#  index_pull_requests_on_source         (source_type,source_id)
#  index_pull_requests_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (repository_id => repositories.id)
#  fk_rails_...  (user_id => users.id)
#
class PullRequest < ApplicationRecord
  belongs_to :repository

  has_many :commits, dependent: :destroy
  has_many :pull_request_reviews, dependent: :destroy
  has_one :slack_message, dependent: :destroy
  has_many :pull_request_changes, dependent: :destroy
  has_one :branch, dependent: :nullify
  has_many :check_runs, through: :branch
  has_many :code_comments, dependent: :destroy

  validate :uniqueness_between_repository_and_source_control_id

  def uniqueness_between_repository_and_source_control_id
    record = PullRequest.by_repository_and_source_control_id(repository, source&.source_control_id)
    errors.add(:repository, 'There is a source_control_id for this repository already') if record&.id != id
  end

  # @TODO: rename to source_control
  belongs_to :source, polymorphic: true

  validates :head, presence: true
  validates :base, presence: true
  validates :title, presence: true
  validates :state, presence: true

  delegate :link, to: :source
  delegate :source_control_id, to: :source

  def self.by_repository_and_source_control_id(repository, source_control_id)
    [GithubPullRequest, AzurePullRequest].lazy.map do |clazz|
      clazz.joins(:pull_request).find_by(source_control_id:,
                                         pull_request: { repository_id: repository&.id })
    end.find(&:itself)&.pull_request
  end

  state_machine :state, initial: :open do
    event :merge! do
      transition open: :merged
    end

    event :cancel! do
      transition open: :cancelled
    end
  end

  def notify_of_creation!(channel, branch, customer, reaction)
    new_pull_request_message = Messages::PullRequestBuilder.new_pull_request_message(self)
    response = Clients::Notifications::Channel.new(customer).send(new_pull_request_message, channel, nil, true)
    slack_message = SlackMessage.new(ts: response['notification_id'], pull_request: self)
    slack_message.save!

    Clients::Notifications::Reactji.new(customer).send(reaction, channel, slack_message.ts) if branch
  end
end
