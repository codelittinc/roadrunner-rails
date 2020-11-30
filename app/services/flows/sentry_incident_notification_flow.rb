# frozen_string_literal: true

module Flows
  class SentryIncidentNotificationFlow < BaseFlow
    delegate :project_name, :issue_id, :event_id, :type, to: :parser

    def execute
      notify_sentry_error_message = Messages::GenericBuilder.notify_sentry_error(title, metadata, user, browser_name, link_sentry, type)
      ServerIncidentService.new.register_incident!(server, notify_sentry_error_message, nil, ServerIncidentService::SENTRY_MESSAGE_TYPE)
    end

    def can_execute?
      server && @params[:project_slug]
    end

    private

    def title
      @title ||= @parser.event_title
    end

    def metadata
      @metadata ||= @parser.event_metadata
    end

    def browser_name
      @browser_name ||= @parser.event_contexts.dig(:browser, :name)
    end

    def user
      @user ||= @parser.event_user
    end

    def link_sentry
      "https://sentry.io/organizations/codelitt-7y/issues/#{issue_id}/events/#{event_id}/?project=#{project_id}"
    end

    def project_id
      @project_id ||= @parser.event_project
    end

    def server
      @server ||= Server.find_by(external_identifier: project_name)
    end
  end
end
