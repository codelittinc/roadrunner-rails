# frozen_string_literal: true

module Authentication
  class GithubController < ApplicationController
    def create
      byebug
    end

    def index
      if params[:code]
        response = JSON.parse(Request.post('https://github.com/login/oauth/access_token', '', {
          client_id: ENV['GITHUB_CLIENT_ID'],
          client_secret: ENV['GITHUB_CLIENT_SECRET'],
          code: params[:code]
        }).body)

        github_auth = GithubAuthentication.new
        github_auth.access_token = response[:access_token]
        github_auth.save!
        render json: {
          status: 'ok'
        }
      else
        redirect_to "https://github.com/login/oauth/authorize?client_id=#{ENV['GITHUB_CLIENT_ID']}"
      end
    end
  end
end
