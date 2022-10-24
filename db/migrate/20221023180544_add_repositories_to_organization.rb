# frozen_string_literal: true

class AddRepositoriesToOrganization < ActiveRecord::Migration[7.0]
  def change
    add_reference :repositories, :organization, null: true, foreign_key: true
  end
end
