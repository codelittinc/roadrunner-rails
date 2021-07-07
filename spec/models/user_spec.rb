# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  github     :string
#  jira       :string
#  slack      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  azure      :string
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:pull_requests) }
  end
end
