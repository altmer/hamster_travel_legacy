# frozen_string_literal: true
class RemoveDenormalizeColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column(:cities, :country_text)
    remove_column(:cities, :country_text_ru)
    remove_column(:cities, :country_text_en)
    remove_column(:cities, :region_text)
    remove_column(:cities, :region_text_ru)
    remove_column(:cities, :region_text_en)
    remove_column(:cities, :denormalized)
  end
end
