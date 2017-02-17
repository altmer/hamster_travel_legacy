# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Api::ActivitiesController do
  let(:user) { FactoryGirl.create(:user) }

  describe '#index' do
    let!(:trip) { FactoryGirl.create(:trip, :with_filled_days) }

    context 'when user is logged in' do
      before { login_user(user) }

      context 'and when there is trip' do
        it 'returns trip days as JSON' do
          get 'index', params: {
            trip_id: trip.id.to_s,
            day_id: trip.days.first.id.to_s
          }, format: :json
          expect(response).to have_http_status 200
          day_json = JSON.parse(response.body)

          expect(day_json['date']).to eq(
            I18n.l(trip.start_date, format: '%d.%m.%Y %A')
          )
          expect(day_json['activities'].count).to eq(
            trip.days.first.activities.count
          )
          expect(day_json['links'].count).to eq(
            trip.days.first.links.count
          )
          expect(day_json['expenses'].count).to eq(
            trip.days.first.expenses.count
          )
          expect(day_json['comment']).to eq(trip.days.first.comment)
          expect(day_json['places'].count).to eq(trip.days.first.places.count)
        end
      end

      context 'and when there is no trip' do
        it 'heads 404' do
          get 'index', params: {
            trip_id: 'no_trip',
            day_id: 'whatever'
          }, format: :json
          expect(response).to have_http_status 404
        end
      end
    end

    context 'when no logged user' do
      it 'behaves the same' do
        get 'index', params: {
          trip_id: trip.id.to_s,
          day_id: trip.days.first.id.to_s
        }, format: :json
        expect(response).to have_http_status 200
        day_json = JSON.parse(response.body)

        expect(day_json['date']).to eq(
          I18n.l(trip.start_date, format: '%d.%m.%Y %A')
        )
        expect(day_json['activities'].count).to eq(
          trip.days.first.activities.count
        )
        expect(day_json['links'].count).to eq(
          trip.days.first.links.count
        )
        expect(day_json['expenses'].count).to eq(
          trip.days.first.expenses.count
        )
        expect(day_json['comment']).to eq(
          trip.days.first.comment
        )
        expect(day_json['places'].count).to eq(
          trip.days.first.places.count
        )
      end
    end
  end

  describe '#create' do
    let(:trip_without_user) { FactoryGirl.create :trip }

    context 'when user is logged in' do
      before { login_user(user) }
      let(:city) { FactoryGirl.create(:city) }
      let(:trip) { FactoryGirl.create :trip, users: [subject.current_user] }
      let(:day) { trip.days.first }
      let(:day_params) do
        {
          day:
              {
                id: day.id.to_s,
                comment: 'new_day_comment',
                places: [
                  {
                    city_id: city.id,
                    city_text: 'City',
                    missing_attr: 'AAAAA'
                  }
                ],
                activities: [
                  {
                    name: 'new_activity',
                    address: '10553 Berlin Randomstr. 12',
                    working_hours: '12 - 18'
                  }
                ]
              }
        }
      end

      context 'and when there is trip' do
        context 'and when input params are valid' do
          it 'updates trip and heads 200' do
            post 'create', params: day_params.merge(
              trip_id: trip.id, day_id: day.id
            ), format: :json
            expect(response).to have_http_status 200
            updated_day = trip.reload.days.first
            expect(updated_day.comment).to eq 'new_day_comment'
            expect(updated_day.places.count).to eq(1)
            expect(updated_day.places.first.city_id).to eq(city.id)
            expect(updated_day.activities.count).to eq(1)
            expect(updated_day.activities.first.name).to eq('new_activity')
            expect(updated_day.activities.first.address).to eq(
              '10553 Berlin Randomstr. 12'
            )
            expect(updated_day.activities.first.working_hours).to eq('12 - 18')
          end
        end

        context 'and when user is not included in trip' do
          it 'heads 403' do
            post 'create', params: day_params.merge(
              trip_id: trip_without_user.id,
              day_id: trip_without_user.days.first.id
            ), format: :json
            expect(response).to have_http_status 403
          end
        end
      end

      context 'and when there is no trip' do
        it 'heads 404' do
          post 'create', params: day_params.merge(
            trip_id: 'no such trip',
            day_id: day.id
          ), format: :json
          expect(response).to have_http_status 404
        end
      end
    end

    context 'when no logged user' do
      let(:trip) { FactoryGirl.create :trip }
      let(:day) { trip.days.first }
      let(:day_params) do
        {
          day:
              {
                id: day.id.to_s,
                comment: 'new_day_comment',
                places: [
                  {
                    city_id: 43_432,
                    city_text: 'City',
                    missing_attr: 'AAAAA'
                  }
                ]
              }
        }
      end
      it 'redirects to sign in' do
        post 'create', params: day_params.merge(
          trip_id: trip.id,
          day_id: day.id
        ), format: :json
        expect(response).to have_http_status 401
      end
    end
  end
end
