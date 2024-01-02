# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

RSpec.describe Flows::Repositories::PullRequest::CodeReview::Flow, type: :service do
  context 'Github JSON' do
    let(:valid_json) { load_flow_fixture('github_change_pull_request.json') }
    let(:closed_pr_json) { load_flow_fixture('github_close_pull_request.json') }

    let(:repository) do
      FactoryBot.create(:repository, name: 'roadrunner-rails')
    end

    let(:pull_request) do
      slack_message = FactoryBot.create(:slack_message, ts: '123')
      FactoryBot.create(:pull_request, source_control_id: 1, repository:, slack_message:,
                                       head: 'DESENV')
    end

    describe '#flow?' do
      context 'returns true when' do
        it 'a pull request exists and it is open' do
          pull_request
          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_truthy
        end
      end

      context 'returns false when' do
        it 'a pull request exists but it is closed' do
          pull_request.merge!

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request exists and action is not synchronize' do
          pull_request

          flow = described_class.new(closed_pr_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request exists and branch name is reserved' do
          pull_request
          invalid_json = valid_json.deep_dup

          reserved_branch_names = %w[master development develop qa]

          reserved_branch_names.each do |branch_name|
            invalid_json[:pull_request][:head][:ref] = branch_name

            flow = described_class.new(invalid_json)

            expect(flow.flow?).to be_falsey
          end
        end

        it 'a pull request exists but it is cancelled' do
          pull_request.cancel!

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request does not exist' do
          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end
      end

      it 'does not throw error for invalid json' do
        flow = described_class.new(JSON.parse('{}'))

        expect { flow.flow? }.to_not raise_error
      end
    end

    describe '#run' do
      it 'creates a new pull request change in the database' do
        VCR.use_cassette('flows#change-pull-request#change-send-message') do
          pull_request

          flow = described_class.new(valid_json)

          expect_any_instance_of(Clients::Notifications::Channel).to receive(:send)

          expect { flow.run }.to change { pull_request.pull_request_changes.count }.by(1)
        end
      end

      it 'sends the right message' do
        VCR.use_cassette('flows#change-pull-request#change-send-right-message') do
          pull_request

          flow = described_class.new(valid_json)

          expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).with(
            ':pencil2: There is a new change!', 'feed-test-automations', '123'
          )

          expect { flow.run }.to change { pull_request.pull_request_changes.count }.by(1)
        end
      end
    end
  end

  context 'Azure JSON' do
    let(:valid_json) { load_flow_fixture('azure_change_pull_request.json') }

    let(:repository) do
      FactoryBot.create(:repository, name: 'ay-pia-web', owner: 'Avant')
    end

    let(:pull_request) do
      slack_message = FactoryBot.create(:slack_message, ts: '123')
      FactoryBot.create(:pull_request, source_control_id: 1, repository:, slack_message:,
                                       head: 'update/add-extra-logic-to-multiple-charts')
    end

    describe '#flow?' do
      context 'returns true when' do
        it 'a pull request exists and it is open' do
          pull_request
          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_truthy
        end
      end

      context 'returns false when' do
        it 'a pull request exists but it is closed' do
          pull_request.merge!

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request exists and branch name is reserved' do
          pull_request
          invalid_json = valid_json.deep_dup

          reserved_branch_names = %w[master development develop qa]

          reserved_branch_names.each do |branch_name|
            invalid_json[:resource][:refUpdates].first[:name] = branch_name

            flow = described_class.new(invalid_json)

            expect(flow.flow?).to be_falsey
          end
        end

        it 'a pull request exists but it is cancelled' do
          pull_request.cancel!

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request does not exist' do
          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end
      end

      it 'does not throw error for invalid json' do
        flow = described_class.new(JSON.parse('{}'))

        expect { flow.flow? }.to_not raise_error
      end
    end

    describe '#run' do
      it 'creates a new pull request change in the database' do
        VCR.use_cassette('flows#azure-change-pull-request#change-send-message') do
          pull_request

          flow = described_class.new(valid_json)

          expect_any_instance_of(Clients::Notifications::Channel).to receive(:send)

          expect { flow.run }.to change { pull_request.pull_request_changes.count }.by(1)
        end
      end

      it 'sends the right message' do
        VCR.use_cassette('flows#change-pull-request#change-send-right-message') do
          pull_request

          flow = described_class.new(valid_json)

          expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).with(
            ':pencil2: There is a new change!', 'feed-test-automations', '123'
          )

          expect { flow.run }.to change { pull_request.pull_request_changes.count }.by(1)
        end
      end
    end
  end
end
