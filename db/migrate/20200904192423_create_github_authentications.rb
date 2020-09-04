class CreateGithubAuthentications < ActiveRecord::Migration[6.0]
  def change
    create_table :github_authentications do |t|
      t.string :access_token
      t.string :refresh_token
      t.integer :refresh_token_expires_in

      t.timestamps
    end
  end
end
