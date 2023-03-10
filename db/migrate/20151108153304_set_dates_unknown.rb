# frozen_string_literal: true
class SetDatesUnknown < ActiveRecord::Migration[5.0]
  def change
    Travels::Trip.all.each { |trip| trip.update_attributes(dates_unknown: false) if trip.dates_unknown.nil? }
  end
end
