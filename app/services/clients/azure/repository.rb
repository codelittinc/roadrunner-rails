# frozen_string_literal: true

module Clients
  module Azure
    class Repository < AzureBase
      def get_repository(repository)
        url = "#{azure_url}git/repositories/#{repository.name}?includeParent=false&api-version=4.1"
        repository = SimpleRequest.get(url, authorization:)
        Clients::Azure::Parsers::RepositoryParser.new(repository)
      end
    end
  end
end
