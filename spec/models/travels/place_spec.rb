# frozen_string_literal: true

# == Schema Information
#
# Table name: places
#
#  id      :integer          not null, primary key
#  day_id  :integer
#  city_id :integer
#

require 'rails_helper'
RSpec.describe Travels::Place do
  let(:place) do
    FactoryGirl.create(:trip, :with_filled_days).days.ordered.first.places.last
  end
  let(:place_empty) do
    FactoryGirl.create(:trip, :with_filled_days).days.ordered.first.places.first
  end

  describe '#city' do
    context 'when city is present' do
      let(:city) { place.city }
      it 'returns city from geo database' do
        expect(city).not_to be_blank
        expect(city.id).to eq place.city_id
        expect(city.name).to eq place.city_text
      end
    end
    context 'when no city' do
      let(:city) { place_empty.city }
      it 'returns nil' do
        expect(city).to be_nil
      end
    end
  end

  describe '#empty?' do
    context 'when place with no data' do
      it 'returns true' do
        expect(place_empty).to be_empty_content
      end
    end
    context 'when place has data' do
      it 'returns false' do
        expect(place).not_to be_empty_content
      end
    end
  end

  describe '#country_code' do
    context 'when city is present' do
      let(:city) { place.city }
      it 'returns country code of city' do
        expect(place.country_code).not_to be_nil
        expect(place.country_code).to eq(city.country_code)
      end
    end

    context 'when no city' do
      let(:country_code) { place_empty.country_code }
      it 'returns nil' do
        expect(country_code).to be_nil
      end
    end
  end
end
