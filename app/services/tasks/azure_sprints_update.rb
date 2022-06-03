# frozen_string_literal: true

module Tasks
  class AzureSprintsUpdate
    DEFAULT_NO_DEVOPS_CODE = 'Not assigned'
    TEAMS = ['Visualization', 'Appraisal', 'Data Team', 'Mobile Team', 'Properties', 'Skyline'].freeze

    def update!
      update_info!
    rescue StandardError
      update!
    end

    def customer
      return @customer if @customer

      @customer ||= Customer.find_or_initialize_by(name: 'Avison Young')
      @customer.save
      @customer
    end

    def sprints_per_team
      @sprints_per_team ||= TEAMS.map { |team| [team, Clients::Azure::Sprint.new.list(team)] }
    end

    def find_user(assigned_to, display_name, customer)
      user = User.search_by_term(assigned_to).first || User.find_by(name: display_name)
      user ||= User.new(azure_devops_issues: assigned_to)
      user.name = display_name
      user.customer = customer
      user.save!
      user
    end

    def update_info!
      customer.sprints.destroy_all

      sprints_per_team.map do |team, sprints|
        sprints.map do |sprint|
          sprint_obj = Sprint.new(
            start_date: Date.parse(sprint.start_date),
            end_date: Date.parse(sprint.end_date),
            name: sprint.name, time_frame: sprint.time_frame,
            team:, customer:
          )
          sprint_obj.save!
          Clients::Azure::Sprint.new.work_items(team, sprint.id).each do |issue|
            assigned_to = issue.assigned_to || DEFAULT_NO_DEVOPS_CODE
            user = find_user(assigned_to, issue.display_name, customer)

            Issue.new(
              story_type: issue.story_type,
              state: issue.state,
              title: issue.title,
              user:,
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
