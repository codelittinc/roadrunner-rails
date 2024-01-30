# frozen_string_literal: true

module Flows
  module Repositories
    module PullRequest
      module Create
        class Flow < BaseSourceControlFlow
          def execute
            return unless pull_request_already_exists?

            user.save unless user.persisted?

            @current_pull_request = create_pull_request!

            return unless @current_pull_request.persisted?

            response = Clients::Notifications::Channel.new(customer).send(new_pull_request_message, channel, nil, true)
            slack_message = SlackMessage.new(ts: response['notification_id'], pull_request: @current_pull_request)
            slack_message.save!

            Clients::Notifications::Reactji.new(customer).send(reaction, channel, slack_message.ts) if branch

            @current_pull_request&.update(ci_state: checkrun_state)
          end

          def can_execute?
            return false if repository.nil?
            return false unless pull_request.nil?
            return false unless parser.new_pull_request_flow?

            !parser.draft && !repository.deployment_branches?(parser.base, parser.head) && repository.valid_base_branch_for_pull_request?(parser.base)
          end

          private

          def pull_request_already_exists?
            pull_request.nil?
          end

          def user
            @user ||= parser.user_by_source_control
          end

          def backstage_user_id
            Clients::Backstage::User.new.list(parser.username)&.first&.id
          end

          def create_pull_request!
            pr = ::PullRequest.new(
              head: parser.head,
              base: parser.base,
              title: parser.title,
              description: parser.description,
              repository:,
              user:,
              backstage_user_id:
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
    end
  end
end
