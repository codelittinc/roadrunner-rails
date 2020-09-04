# frozen_string_literal: true

module Clients
  module Github
    class GithubBase
      def initialize(access_token)
        @client = Octokit::Client.new(access_token: GithubAuthentication.last.access_token)
      end
    end
  end
end
