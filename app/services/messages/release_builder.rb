# frozen_string_literal: true

module Messages
  class ReleaseBuilder
    def self.branch_compare_message(commits, format, repository_name)
      title = "Available in the release of *#{repository_name}*:\n"
      changes = ChangelogsService.changes(commits)

      changelog = changes.map do |change|
        base = " - #{change[:message].lines.first.gsub("\n", '').gsub('\n', '')}"
        task_manager_references = change[:references][:task_manager]

        links = task_manager_references.map do |reference|
          code = reference[:reference_code]
          link = reference[:link]

          if format == 'slack'
            "<#{link}|#{code}>"
          else
            "[#{code}](#{link})"
          end
        end.join(' ')
        "#{base} #{links}"
      end.join("\n")
      "#{title}#{changelog}".strip
    end

    def self.notify_release_action(action, environment, user_name, repository_name)
      "#{action.capitalize} release to *#{repository_name}* *#{environment.upcase}* triggered by @#{user_name}"
    end

    def self.notify_branch_existence(branch_name, exist)
      "Hey the branch `#{branch_name}` #{'does not' unless exist} exist"
    end

    def self.notify_no_commits_changes(environment, repository_name)
      "Hey the *#{repository_name}* *#{environment.upcase}* environment is already up to date"
    end
  end
end
