# frozen_string_literal: true

module Clients
  module Jira
    class Project < JiraBase
      def list
        projects_url = build_api_url('/project/search')
        body = SimpleRequest.get(projects_url, authorization:)
        body['values']
      end
    end
  end
end
