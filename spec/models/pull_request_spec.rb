# frozen_string_literal: true

# == Schema Information
#
# Table name: pull_requests
#
#  id                :bigint           not null, primary key
#  base              :string
#  ci_state          :string
#  description       :string
#  draft             :boolean          default(FALSE), not null
#  head              :string
#  merged_at         :datetime
#  source_type       :string
#  state             :string
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  backstage_user_id :integer
#  repository_id     :bigint
#  source_id         :bigint
#  user_id           :bigint
#
# Indexes
#
#  index_pull_requests_on_repository_id  (repository_id)
#  index_pull_requests_on_source         (source_type,source_id)
#  index_pull_requests_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (repository_id => repositories.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe PullRequest, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:head) }
    it { is_expected.to validate_presence_of(:base) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:state) }
  end

  describe 'associations' do
    it { should belong_to(:repository) }
    it { should belong_to(:source) }
    it { should have_many(:commits).dependent(:destroy) }
    it { should have_one(:slack_message).dependent(:destroy) }
    it { should have_one(:branch).dependent(:nullify) }
    it { should have_many(:pull_request_reviews).dependent(:destroy) }
    it { should have_many(:pull_request_changes).dependent(:destroy) }
    it { should have_many(:check_runs).through(:branch) }

    it 'validates uniqueness between repository and source control id' do
      repository = FactoryBot.create(:repository)
      FactoryBot.create(:pull_request, repository:, source_control_type: 'azure', source_control_id: 1)

      expect do
        FactoryBot.create(:pull_request, repository:, source_control_type: 'azure', source_control_id: 1)
      end.to raise_error(ActiveRecord::RecordInvalid,
                         /Repository There is a source_control_id for this repository already/)
    end
  end

  describe 'state machine' do
    it "defaults to 'open'" do
      pr = FactoryBot.build(:pull_request)
      expect(pr.state).to eql('open')
    end

    it 'saves the default state' do
      pr = FactoryBot.create(:pull_request)
      pr.save!
      expect(PullRequest.last.id).to eql(pr.id)
      expect(PullRequest.last.state).to eql('open')
    end

    describe 'merge!' do
      it "changes the state to 'merged'" do
        pr = FactoryBot.create(:pull_request)
        pr.merge!
        pr.reload
        expect(pr.state).to eql('merged')
      end
    end

    describe 'cancel!' do
      it "changes the state to 'cancelled'" do
        pr = FactoryBot.create(:pull_request)
        pr.cancel!
        pr.reload
        expect(pr.state).to eql('cancelled')
      end
    end

    describe '#link' do
      it 'returns a valid github link' do
        repository = FactoryBot.create(:repository, owner: 'repo-owner', name: 'repo-name')
        pr = FactoryBot.create(:pull_request, repository:, source_control_id: 1)
        expect(pr.link).to eql('https://github.com/repo-owner/repo-name/pull/1')
      end
    end
  end
end
