# frozen_string_literal: true

module Flows
  module Repositories
    module PullRequest
      module CodeReview
        class Flow < BaseSourceControlFlow
          def execute
            PullRequestChange.create!(pull_request:)

            change_pull_request_message = Messages::PullRequestBuilder.change_pull_request_message

            message_ts = pull_request.slack_message.ts

            return unless message_ts

            Clients::Notifications::Channel.new(customer).send(change_pull_request_message, channel, message_ts)
          end

          def can_execute?
            return false unless pull_request

            reserved_branch = [pull_request.repository.base_branch, 'development', 'qa'].include? parser.head

            parser.new_change_pull_request_code_flow? && !reserved_branch && pull_request&.open?
          end

          private

          def pull_request
            @pull_request ||= ::PullRequest.find_by(repository:, head: parser.head, state: 'open')
          end
        end
      end
    end
  end
end
