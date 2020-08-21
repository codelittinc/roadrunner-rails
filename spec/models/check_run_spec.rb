# == Schema Information
#
# Table name: check_runs
#
#  id         :bigint           not null, primary key
#  state      :string
#  commit_sha :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe CheckRun, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:state) }
  end
end
