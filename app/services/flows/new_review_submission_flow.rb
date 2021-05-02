# frozen_string_literal: true

module Flows
  class NewReviewSubmissionFlow < BaseGithubFlow
    def execute
      if pull_request_review
        pull_request_review.update(state: parser.review_state)
      else
        PullRequestReview.create(pull_request: pull_request, username: parser.review_username, state: parser.review_state)
      end

      send_message
    end

    def can_execute?
      return false unless parser.review
      return false unless pull_request
      return false unless slack_message

      action == 'submitted'
    end

    private

    def pull_request
      @pull_request ||= PullRequest.by_repository_and_source_control_id(repository, parser.source_control_id)
    end

    def pull_request_review
      @pull_request_review ||= PullRequestReview.find_by(pull_request: pull_request, username: parser.review_username)
    end

    def action
      @action ||= @params[:action]
    end

    def slack_message
      @slack_message = pull_request.slack_message
    end

    def github_pull_request
      @github_pull_request ||= Clients::Github::PullRequest.new.get(repository.full_name, pull_request.source_control_id)
    end

    def send_message
      slack_ts = slack_message.ts
      if parser.review_state == PullRequestReview::REVIEW_STATE_CHANGES_REQUESTED
        message = Messages::PullRequestBuilder.notify_changes_request
        Clients::Slack::ChannelMessage.new.send(message, channel, slack_ts)
      elsif parser.review_body != ''
        message = Messages::PullRequestBuilder.notify_new_message
        Clients::Slack::ChannelMessage.new.send(message, channel, slack_ts)
      elsif !github_pull_request[:mergeable] && github_pull_request[:mergeable_state] == 'dirty' && pull_request.user.slack
        message = Messages::PullRequestBuilder.notify_pr_conflicts(pull_request)
        Clients::Slack::DirectMessage.new.send(message, pull_request.user.slack)
      end
    end
  end
end
