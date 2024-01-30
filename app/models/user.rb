# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  active              :boolean          default(TRUE)
#  azure               :string
#  azure_devops_issues :string
#  github              :string
#  jira                :string
#  name                :string
#  slack               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  customer_id         :bigint
#
# Indexes
#
#  index_users_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#
class User < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_term, against: %i[jira slack github azure azure_devops_issues]

  has_many :pull_requests
  has_many :issues
  belongs_to :customer, optional: true

  def self.find_existing_user(user)
    find_duplicates(user).first
  end

  def self.find_duplicates(user)
    User.all.select do |curr_user|
      user_clean_name = user.name&.split(/[\s, .]/)&.map(&:capitalize)&.join(' ')
      curr_user_clean_name = curr_user.name&.split(/[\s, .]/)&.map(&:capitalize)&.join(' ')

      result = (user.github.present? && user.github == curr_user.github) ||
               (user.azure.present? && user.azure == curr_user.azure) ||
               (user.azure_devops_issues.present? && user.azure_devops_issues == curr_user.azure_devops_issues) ||
               (user.jira.present? && user.jira == curr_user.jira) ||
               (user.name.present? && curr_user.name.present? && (!(user_clean_name =~ /#{curr_user_clean_name}/).nil? || !(curr_user_clean_name =~ /#{user_clean_name}/).nil?))

      result
    end
  end

  def self.find_all_duplicates
    users = order(:id)
    duplicates = []

    users.each do |user|
      dups = find_duplicates(user)
      duplicates << dups unless dups.size < 2
    end

    duplicates
  end
end
