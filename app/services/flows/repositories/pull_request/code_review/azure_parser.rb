# frozen_string_literal: true

module Flows
  module Repositories
    module PullRequest
      module CodeReview
        class AzureParser < Parsers::BaseAzureParser
          attr_reader :review_comment,
                      :repository_name,
                      :owner,
                      :source_control_id,
                      :mention_regex,
                      :user_identifier,
                      :review_state,
                      :first_name,
                      :last_name,
                      :email

          def can_parse?
            @json[:eventType] == 'ms.vss-code.git-pullrequest-comment-event'
          end

          def parse!
            @repository_name = @json.dig(:resource, :pullRequest, :repository, :name)
            @owner = @json.dig(:resource, :pullRequest, :repository, :project, :name)
            @source_control_id = @json.dig(:resource, :pullRequest, :pullRequestId)
            @mention_regex = /<([\da-zA-Z-]+)>/

            @review_comment = @json.dig(:resource, :comment, :content)
            @user_identifier = @json.dig(:resource, :comment, :author, :uniqueName)
            @email = @user_identifier
            display_name = @json.dig(:resource, :comment, :author, :displayName)
            @first_name, @last_name = display_name.split
            @review_state = 'commented'
          end
        end
      end
    end
  end
end
