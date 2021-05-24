# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::Branch, type: :service do
  let(:repository) do
    FactoryBot.create(:repository, name: 'ay-users-api-test')
  end

  describe '#commits' do
    it 'returns a list of commits' do
      VCR.use_cassette('azure#branch#commits') do
        commits = described_class.new.commits(repository, 'master')
        expect(commits.size).to eql(14)
      end
    end
  end

  describe '#compare' do
    # @TODO: we need to add an example that brings more than one commit item
    it 'returns a list the commits difference between two branches' do
      VCR.use_cassette('azure#branch#compare') do
        commits = described_class.new.compare(repository, 'master', 'feat/cool-test')
        expect(commits.size).to eql(1)
      end
    end
  end

  describe '#branch_exists' do
    it 'returns true when the branch exists' do
      VCR.use_cassette('azure#branch#branch_exists_true') do
        exists = described_class.new.branch_exists?(repository, 'roadrunner/test')
        expect(exists).to be_truthy
      end
    end

    it 'returns true when the branch exists' do
      VCR.use_cassette('azure#branch#branch_exists_false') do
        exists = described_class.new.branch_exists?(repository, 'roadrunner/test1234')
        expect(exists).to be_falsey
      end
    end
  end
end
