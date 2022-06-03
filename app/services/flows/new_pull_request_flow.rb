# frozen_string_literal: true

module Flows
  class NewPullRequestFlow < BaseSourceControlFlow
    def execute
      return unless pull_request_already_exists?

      user.save unless user.persisted?

      @current_pull_request = create_pull_request!

      return unless @current_pull_request.persisted?

      response = Clients::Slack::ChannelMessage.new(customer).send(new_pull_request_message, channel, nil, true)
      slack_message = SlackMessage.new(ts: response['notification_id'], pull_request: @current_pull_request)
      slack_message.save!

      Clients::Slack::Reactji.new(customer).send(reaction, channel, slack_message.ts) if branch

      @current_pull_request&.update(ci_state: checkrun_state)
    end

    def can_execute?
      return if repository.nil?
      return unless pull_request.nil?
      return unless parser.new_pull_request_flow?

      !parser.draft && !PullRequest.deployment_branches?(parser.base, parser.head)
    end

    private

    def pull_request_already_exists?
      pull_request.nil?
    end

    def user
      @user ||= parser.user_by_source_control(customer)
    end

    def create_pull_request!
      pr = PullRequest.new(
        head: parser.head,
        base: parser.base,
        title: parser.title,
        description: parser.description,
        repository:,
        user:
      )

      pr.source = parser.build_source(pr)
      pr.save
      pr
    end

    def new_pull_request_message
      Messages::PullRequestBuilder.new_pull_request_message(@current_pull_request)
    end

    def branch
      return @branch if @branch

      @branch = Branch.where(name: @current_pull_request.head, repository:).first_or_create
      @branch.update(pull_request: @current_pull_request)
      @branch
    end

    def checkrun
      @checkrun ||= CheckRun.where(branch:).last
    end

    def checkrun_state
      @checkrun_state ||= checkrun&.state || 'pending'
    end

    def reaction
      reacts = { 'success' => 'white_check_mark',
                 'failure' => 'rotating_light',
                 'pending' => 'hourglass' }

      reacts[checkrun&.state] || 'hourglass'
    end
  end
end
