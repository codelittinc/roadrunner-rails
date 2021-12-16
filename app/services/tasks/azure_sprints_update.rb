# frozen_string_literal: true

module Tasks
  class AzureSprintsUpdate
    DEFAULT_NO_DEVOPS_CODE = 'Not assigned'
    TEAMS = ['Visualization', 'Appraisal', 'Data Team', 'Mobile Team', 'Properties', 'Appraisal', 'Skyline'].freeze

    def self.update!
      update_info!
    rescue StandardError
      update!
    end

    def self.update_info!
      Issue.delete_all
      Sprint.delete_all

      customer = Customer.find_by(name: 'Codelitt')

      # pull latest data
      sprints_per_team = TEAMS.map { |team| [team, Clients::Azure::Sprint.new.list(team)] }

      sprints_per_team.map do |team, sprints|
        sprints.map do |sprint|
          sprint_obj = Sprint.new(
            start_date: Date.parse(sprint.start_date),
            end_date: Date.parse(sprint.end_date),
            name: sprint.name,
            time_frame: sprint.time_frame, team: team
          )
          sprint_obj.save!
          Clients::Azure::Sprint.new.work_items(team, sprint.id).each do |issue|
            assigned_to =  issue.assigned_to || DEFAULT_NO_DEVOPS_CODE
            user = User.search_by_term(assigned_to).first
            user ||= User.new(azure_devops_issues: assigned_to)
            user.name = issue.display_name
            user.customer = customer
            user.save!

            Issue.new(
              story_type: issue.story_type,
              state: issue.state,
              title: issue.title,
              user: user,
              sprint: sprint_obj,
              story_points: issue.story_points,
              tags: issue.tags
            ).save!
          end
        end
      end
    end
  end
end
