require 'rails_helper'

RSpec.describe Repository, type: :model do
  describe 'associations' do
    it { should have_many(:servers) }
  end
end