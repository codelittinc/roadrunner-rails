# frozen_string_literal: true

module Tasks
  class UpdatePullRequestsCommentsTask
    def update!
      pull_requests.each do |pull_request|
        Rails.logger.debug { "Updating comments for pull request #{pull_request.id}" }
        CodeCommentsCreator.new(pull_request, source_control_client(pull_request)).create
      end
      nil
    end

    def pull_requests
      two_days_ago = 2.days.ago.beginning_of_day
      PullRequest.joins(:repository)
                 .where.not(repository: { external_project_id: nil })
                 .where('pull_requests.created_at >= ? OR pull_requests.merged_at >= ?', two_days_ago, two_days_ago)
    end

    def source_control_client(pull_request)
      return Clients::Azure::PullRequest if pull_request.source_type == 'AzurePullRequest'

      Clients::Github::PullRequest if pull_request.source_type == 'GithubPullRequest'
    end
  end
end
