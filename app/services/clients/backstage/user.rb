# frozen_string_literal: true

class BackstageUser
  attr_reader :email, :id, :slack

  def initialize(params)
    @params = params
    @email = params['email']
    @id = params['id']
    @slack = identifier('slack')
  end

  def identifier(service_name)
    @params['user_service_identifiers']&.find { |service| service['service_name'] == service_name }&.dig('identifier')
  end
end

module Clients
  module Backstage
    class User < Client
      def list(*query)
        query_string = query.join(',')
        response = Request.get("#{@url}/users?query=#{query_string}", authorization)
        response.map { |user| BackstageUser.new(user) }
      end

      def create(body)
        response = Request.post("#{@url}/users", authorization, body)
        BackstageUser.new(JSON.parse(response.body))
      end

      def find_or_create_by(query, body)
        list(query).first || create(body)
      end
    end
  end
end
