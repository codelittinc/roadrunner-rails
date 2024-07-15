# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'pagerduty'
require 'redis'
require 'json'

module Tasks
  class AfiniumServersTask
    INTEGRATION_KEY = ENV.fetch('AFINIUM_PAGERDUTY_INTEGRATION_KEY', nil)
    REDIS_URL = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
    URLS = JSON.parse(ENV.fetch('AFINIUM_URLS', '[]')).freeze

    def self.check_afinium_servers!
      redis = Redis.new(url: REDIS_URL)

      URLS.each do |url_info|
        url = url_info['url']
        environment = url_info['environment']
        description = url_info['description']
        notification_key = "pagerduty_last_notification_#{url.gsub(/[^0-9A-Za-z]/, '_')}"

        if server_down?(url)
          if notification_recently_sent?(redis, notification_key)
            Rails.logger.info { "Notification already sent in the last 5 minutes for #{url}. Skipping." }
          else
            Rails.logger.info { "Server is down at #{url}. Sending notification to PagerDuty." }
            send_pagerduty_notification(url, environment, description)
            update_last_notification_time(redis, notification_key)
          end
        else
          Rails.logger.info { "Server is up and running at #{url}." }
        end
      end
    end

    def self.server_down?(url, attempts = 3)
      uri = URI.parse(url)
      attempts.times do
        response = Net::HTTP.get_response(uri)
        return false if response.code == '200' || response.code == '301'
      rescue StandardError => e
        Rails.logger.info { "Error checking server status: #{e.message}" }
      end
      true
    end

    def self.send_pagerduty_notification(url, environment, description)
      pagerduty = Pagerduty.build(integration_key: INTEGRATION_KEY, api_version: 2)
      summary = "Server Down Alert: The Afinium #{environment} #{description} was triggered"
      pagerduty.trigger(
        summary:,
        source: 'monitoring_script',
        severity: 'critical',
        custom_details: {
          url:,
          issue: 'Server is not responding to HTTP requests.'
        }
      )
      Rails.logger.info { 'Notification sent to PagerDuty.' }
    end

    def self.notification_recently_sent?(redis, notification_key)
      last_notification_time = redis.get(notification_key)
      return false unless last_notification_time

      Time.zone.now - Time.zone.parse(last_notification_time) < 300 # 300 seconds = 5 minutes
    end

    def self.update_last_notification_time(redis, notification_key)
      redis.set(notification_key, Time.zone.now.to_s)
    end
  end
end
