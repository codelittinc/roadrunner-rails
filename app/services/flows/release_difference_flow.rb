# frozen_string_literal: true

module Flows
  class ReleaseDifferenceFlow < BaseFlow
    RELESES_NOT_FOUND_MESSAGE = "I couldn't compare your releases. There is possibly a typo in their names or they are missing."

    def execute
      return Clients::Slack::DirectMessage.new.send(RELESES_NOT_FOUND_MESSAGE, user_name) unless base_release.present? && head_release.present?

      differences = head_release.commits.where("NOT EXISTS (
          SELECT 1 FROM commit_releases
          WHERE commit_releases.commit_id = commits.id
          AND commit_releases.release_id IN (?)
        )", [base_release])

      changelog = differences.map do |difference|
        " - #{difference.message}"
      end.join("\n")

      message = "The differente between #{base_release.version} and #{head_release.version} is:\n#{changelog}".strip

      Clients::Slack::DirectMessage.new.send(message, user_name)
    end

    def can_execute?
      text.present? &&
        text.include?('release diff') &&
        text.split.size == 5
    end

    private

    def user_name
      @user_name ||= @params[:user_name]
    end

    def repository
      repository_name = text.split.third
      Repository.find_by(name: repository_name)
    end

    def head_release
      head_name = text.split.last
      Release.where(version: head_name).find { |r| r.application.repository == repository }
    end

    def base_release
      base_name = text.split.fourth
      Release.where(version: base_name).find { |r| r.application.repository == repository }
    end

    def text
      @text ||= @params[:text]
    end
  end
end
