class RemoveTextsFromEverywhere < ActiveRecord::Migration
  def change
    remove_column(:places, :city_text)
    remove_column(:transfers, :city_from_text)
    remove_column(:transfers, :city_to_text)
    remove_column(:users, :home_town_text)
  end
end