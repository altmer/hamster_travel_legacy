class AddGoogleRefreshTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :google_oauth_refresh_token, :string
  end
end
