# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Trips::Days do
  def first_day_of(tr)
    Trips::Days.list(tr.reload).first
  end

  let(:trip) { FactoryGirl.create(:trip) }
  let(:day) { first_day_of trip }

  describe '#process' do
    context 'when has activities' do
      let(:params) do
        [
          {
            name: 'name 1'
          }.with_indifferent_access,
          {
            name: 'name 2'
          }.with_indifferent_access,
          {
            name: 'name 3'
          }.with_indifferent_access,
          {
            name: '',
            comment: 'some comment'
          }.with_indifferent_access
        ]
      end

      it 'creates new activities skipping activity without name' do
        Trips::Days.save_activities(day, activities: params)
        updated_day = first_day_of trip
        activities = Trips::Activities.list(updated_day)

        expect(activities.count).to eq 3
        activities.each_with_index do |act, index|
          expect(act.name).to eq "name #{index + 1}"
          expect(act.order_index).to eq index
        end
      end

      it 'reorders activities' do
        Trips::Days.save_activities(day, activities: params)
        original_day = first_day_of trip
        original_activities = Trips::Activities.list(original_day)

        old_activities = params
        old_activities.each_with_index do |act, index|
          act[:id] = original_activities[index].id.to_s
        end
        params = [old_activities[2], old_activities[0], old_activities[1]]

        Trips::Days.save_activities(day, activities: params)

        updated_day = first_day_of trip
        activities = Trips::Activities.list(updated_day)
        expect(activities.count).to eq 3
        activities.each_with_index do |act, index|
          expect(act.name).to eq "name #{((index + 2) % 3) + 1}"
          expect(act.order_index).to eq index
          expect(act.id).to eq original_activities[(index + 2) % 3].id
        end
      end
    end
  end
end
