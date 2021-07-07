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
class User < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_term, against: %i[jira slack github azure]

  has_many :pull_requests
end
