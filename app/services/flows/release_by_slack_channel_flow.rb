# frozen_string_literal: true

module Flows
  class ReleaseBySlackChannelFlow < BaseFlow
    UPDATE_ACTION = 'update'

    def execute
      Clients::Notifications::Channel.new(customer).send(release_message, channel_name)

      if Versioning.release_candidate_env? environment
        call_qa_release
      elsif Versioning.release_stable_env? environment
        call_prod_release
      end
    end

    def flow?
      return false if text.nil? || text.blank?
      return false unless contains_tag_all?
      return false unless action == UPDATE_ACTION

      return false unless slack_configs
      return false unless Versioning.valid_env? environment

      words.size == 3
    end

    private

    def text
      @text ||= @params[:text]
    end

    def words
      @words ||= text.split
    end

    def channel_name
      @channel_name ||= @params[:channel_name]
    end

    def channel_id
      @channel_id ||= @params[:channel_id]
    end

    def user_name
      @user_name ||= @params[:user_name]
    end

    def action
      @action ||= words.first
    end

    def contains_tag_all?
      words.second == 'all'
    end

    def environment
      @environment ||= words.last
    end

    def slack_configs
      @slack_configs ||= SlackRepositoryInfo.by_deploy_channel(channel_name, channel_id)
    end

    def release_message
      @release_message ||= Messages::ReleaseBuilder.notify_release_action(UPDATE_ACTION, environment, user_name,
                                                                          channels_repositories.map(&:name).join(', '))
    end

    def channels_repositories
      @channels_repositories ||= Repository.where(slack_repository_info: slack_configs)
    end

    def customer
      channels_repositories.first.project.customer
    end

    def call_qa_release
      channels_repositories.each do |repository|
        next if repository.deploy_type != Repository::TAG_DEPLOY_TYPE

        current_releases = source_control_client.new(repository).list_releases
        Flows::SubFlows::ReleaseCandidateFlow.new(channel_name, current_releases, repository, environment).execute
      end
    end

    def call_prod_release
      channels_repositories.each do |repository|
        next if repository.deploy_type != Repository::TAG_DEPLOY_TYPE

        current_releases = source_control_client.new(repository).list_releases
        Flows::SubFlows::ReleaseStableFlow.new(channel_name, current_releases, repository, environment).execute
      end
    end
  end
end
