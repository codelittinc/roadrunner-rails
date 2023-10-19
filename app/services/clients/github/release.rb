# frozen_string_literal: true

module Clients
  module Github
    class Release < GithubBase
      def list(repository)
        current_page = 0
        per_page = 100
        releases = []
        max_not_reached = true

        while max_not_reached
          current_page += 1
          new_releases = list_releases(repository, per_page, current_page)
          max_not_reached = new_releases.size == per_page
          releases = [releases, new_releases].flatten
          releases = releases.sort_by(&:created_at)
        end

        releases.map do |release|
          Clients::Github::Parsers::ReleaseParser.new(release)
        end
      end

      def create(repository, tag_name, target, body, prerelease)
        release = @client.create_release(repository.full_name, tag_name, {
                                           target_commitish: target,
                                           body:,
                                           prerelease:
                                         })
        Clients::Github::Parsers::ReleaseParser.new(release)
      end

      # @TODO: review this method, it does not seem to work
      def delete(url)
        @client.delete_release(url)
      end

      def list_releases(repository, per_page, page_number)
        @client.list_releases(repository.full_name, {
                                           per_page: per_page,
                                           page: page_number
                                         })
      end
    end
  end
end
