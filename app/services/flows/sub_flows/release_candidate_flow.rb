# frozen_string_literal: true

module Flows
  module SubFlows
    class ReleaseCandidateFlow < BaseReleaseSubFlow
      DEFAULT_TAG_NAME = "rc.1.v0.0.0"
      RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/
      RELEASE_CANDIDATE_VERSION_REGEX = /^rc\.(\d+)\./

      def execute
        if source_control_release_commits.empty?
          notify_no_changes_between_releases!
          return
        end

        source_control_client.create_release(
          version,
          base_branch,
          github_message,
          true
        )

        Clients::Notifications::Channel.new(@customer).send(slack_message, channel)

        update_application_version!
      end

      private

      def release_commits
        CommitsMatcher.new(source_control_release_commits).commits
      end

      def source_control_release_commits
        return @source_control_release_commits if @source_control_release_commits

        @source_control_release_commits = if @releases.empty?
            source_control_client.list_branch_commits(base_branch).reverse
          else
            source_control_client.compare_commits(version_resolver.latest_tag_name,
                                                  base_branch)
          end
      end

      def version_resolver
        @version_resolver ||= Versioning::ReleaseVersionResolver.new(environment, tag_names, "update")
      end
    end
  end
end
