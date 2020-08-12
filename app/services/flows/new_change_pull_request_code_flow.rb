module Flows
  class NewChangePullRequestCodeFlow < BaseFlow
    def execute
      PullRequestChange.create!(
        pull_request: pull_request
      )

      change_pull_request_message = Messages::Builder.change_pull_request_message

      message_ts = pull_request.slack_message.ts

      return unless message_ts

      Clients::Slack::ChannelMessage.new.send(change_pull_request_message, channel, message_ts)
    end

    def flow?
      return false unless @params[:pull_request]

      branch_name = change_pull_request_data[:branch_name]
      reserved_branch = %w[master development develop qa].include? branch_name

      action == 'synchronize' && !reserved_branch && pull_request&.open?
    end

    private

    def action
      @params[:action]
    end

    def change_pull_request_data
      @change_pull_request_data ||= Parsers::Github::NewChangePullRequestParser.new(@params).parse
    end

    def pull_request
      @pull_request ||= PullRequest.where(github_id: change_pull_request_data[:github_id]).last
    end

    def repository
      @repository ||= pull_request.repository
    end

    def channel
      @channel ||= repository.slack_repository_info.dev_channel
    end
  end
end
