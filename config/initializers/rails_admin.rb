# frozen_string_literal: true

require 'nested_form/engine'
require 'nested_form/builder_mixin'

require Rails.root.join('app/services/admin/actions/replay_flow.rb')

RailsAdmin.config do |config|
  config.asset_source = :sprockets
  ### Popular gems integration

  if ENV.fetch('ENABLE_AUTH', nil) == 'true'
    config.authenticate_with do
      authenticate_or_request_with_http_basic('Login required') do |username, password|
        user = UserAdmin.where(username:).or(UserAdmin.where(email: username)).first
        user&.authenticate(password)
      end
    end
  end

  RailsAdmin.config FlowRequest do
    show do
      include_all_fields
      field :json do
        formatted_value do
          bindings[:view].render partial: 'rails_admin/main/json_formatted', locals: { object: bindings[:object] }
        end
      end
    end
  end

  RailsAdmin.config User do
    list do
      include_fields :github, :azure_devops_issues, :slack, :azure, :jira, :id, :name
    end
  end

  RailsAdmin.config FlowRequest do
    list do
      include_fields :json, :executed, :flow_name, :error_message, :created_at
    end
  end

  RailsAdmin.config Application do
    list do
      include_fields :id, :environment, :repository
    end
  end

  RailsAdmin.config Server do
    list do
      include_fields :id, :link, :active, :environment
    end
  end

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.main_app_name = %w[Roadrunner Admin]
  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard do
      statistics true
    end
    index # mandatory
    new
    show
    edit
    delete

    replay_flow
    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
