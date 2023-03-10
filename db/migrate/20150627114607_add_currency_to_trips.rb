# frozen_string_literal: true
class AddCurrencyToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :currency, :string

    Travels::Trip.reset_column_information

    Travels::Trip.all.each do |trip|
      trip.update_attributes(currency: 'RUB')
    end
  end
end
