# frozen_string_literal: true

module Tasks
  class JiraSprintsUpdate
    DEFAULT_NO_DEVOPS_CODE = 'Not assigned'

    def update!
      update_info!
    rescue StandardError
      update!
    end

    def customer
      return @customer if @customer

      @customer ||= Customer.find_or_initialize_by(name: 'Codelitt')
      @customer.save
      @customer
    end

    def projects
      @projects ||= Clients::Jira::Board.new.list
    end

    def sprints_per_team
      @sprints_per_team ||= projects.map { |team| [team, Clients::Jira::Sprint.new.list(team['id'])] }
    end

    def update_info!
      customer.sprints.destroy_all

      sprints_per_team.each do |team, sprints|
        sprints.each do |sprint|
          sprint_obj = new_sprint(sprint, customer, team)

          sprint_obj.save!
          Clients::Jira::Issue.new.list_sprint_issues(sprint['id']).each do |issue|
            fields = issue['fields']
            assigned_to = fields.dig('assignee', 'accountId') || DEFAULT_NO_DEVOPS_CODE
            user = User.search_by_term(assigned_to).first
            user ||= User.new(jira: assigned_to)
            user.name = fields.dig('assignee', 'displayName')
            user.customer = customer
            user.save!

            Issue.new(
              story_type: fields.dig('issuetype', 'name'),
              state: fields.dig('status', 'name'),
              title: fields['summary'],
              user:,
              sprint: sprint_obj,
              story_points: fields['customfield_10023']&.to_f,
              tags: fields['customfield_10033']&.join(', ')
            ).save!
          end
        end
      end
    end

    def new_sprint(sprint, customer, team)
      Sprint.new(
        start_date: sprint['startDate'].nil? ? nil : Date.parse(sprint['startDate']),
        end_date: sprint['endDate'].nil? ? nil : Date.parse(sprint['endDate']),
        name: sprint['name'],
        team: team['name'],
        customer: customer,
        time_frame: sprint['state']
      )
    end
  end
end
