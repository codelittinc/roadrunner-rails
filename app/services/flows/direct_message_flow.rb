# frozen_string_literal: true

module Flows
  class DirectMessageFlow < BaseFlow
    def execute
      # @TODO - use the message, build a response, and reply to the user

      response = message.include?('is kaio a robot?') ? 'Yes, he is!' : URI.parse("https://letmegpt.com?q=#{message}").to_s
      Clients::Notifications::Channel.new.send(
        response,
        slack_channel
      )
    end

    def flow?
      @params[:type] == 'event_callback' &&
        %w[message app_mention].include?(@params[:event]&.dig(:type)) &&
        human_message?
    end

    private

    def human_message?
      @params[:event][:bot_id].blank?
    end

    def message
      @message ||= @params[:event][:text].gsub(/<[^>]*>/, '').chomp
    end

    def slack_channel
      @params[:event][:channel]
    end
  end
end
