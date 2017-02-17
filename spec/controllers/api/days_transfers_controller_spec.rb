# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Api::DaysTransfersController do
  let(:user) { FactoryGirl.create(:user) }

  describe '#index' do
    let(:trip) { FactoryGirl.create(:trip, :with_filled_days) }

    context 'when user is logged in' do
      before { login_user(user) }

      context 'and when there is trip' do
        it 'returns trip days as JSON' do
          get 'index', params: { trip_id: trip.id.to_s }, format: :json
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)['days']
          expect(json.count).to eq(3)
          expect(json.first['date']).to eq(
            I18n.l(trip.start_date, format: '%d.%m.%Y %A')
          )
          expect(json.first['transfers'].count).to eq(
            trip.days.first.transfers.count
          )
          expect(json.first['activities']).to be_nil
        end
      end

      context 'and when there is no trip' do
        it 'heads 404' do
          get 'index', params: { trip_id: 'no_trip' }, format: :json
          expect(response).to have_http_status 404
        end
      end

      context 'when trip is private' do
        let(:private_trip) do
          FactoryGirl.create(:trip, :with_filled_days, private: true)
        end

        it 'heads 403' do
          get 'index', params: { trip_id: private_trip.id.to_s }, format: :json
          expect(response).to have_http_status 403
        end
      end

      context 'when trip is private and current_user is one of participants' do
        let(:private_trip) do
          FactoryGirl.create(
            :trip,
            :with_filled_days,
            private: true,
            users: [subject.current_user]
          )
        end

        it 'heads 403' do
          get 'index', params: { trip_id: private_trip.id.to_s }, format: :json

          expect(response).to have_http_status 200

          json = JSON.parse(response.body)['days']
          expect(json.count).to eq(3)
          expect(json.first['date']).to eq(
            I18n.l(private_trip.start_date, format: '%d.%m.%Y %A')
          )
          expect(json.first['transfers'].count).to eq(
            private_trip.days.first.transfers.count
          )
          expect(json.first['activities']).to be_nil
        end
      end
    end

    context 'when no logged user' do
      it 'behaves the same' do
        get 'index', params: { trip_id: trip.id.to_s }, format: :json
        expect(response).to have_http_status 200
        json = JSON.parse(response.body)['days']
        expect(json.count).to eq(3)
        expect(json.first['date']).to eq(
          I18n.l(trip.start_date, format: '%d.%m.%Y %A')
        )
      end

      context 'when trip is private' do
        let(:private_trip) do
          FactoryGirl.create(:trip, :with_filled_days, private: true)
        end

        it 'heads 403' do
          get 'index', params: { trip_id: private_trip.id.to_s }, format: :json
          expect(response).to have_http_status 403
        end
      end
    end
  end

  describe '#create' do
    let(:city1) { FactoryGirl.create(:city) }
    let(:city2) { FactoryGirl.create(:city) }

    context 'when user is logged in' do
      before { login_user(user) }

      let(:day) { trip.days.first }
      let(:days_params) do
        {
          days:
              [
                {
                  id: day.id.to_s,
                  places: [
                    {
                      city_id: city2.id,
                      city_text: 'City',
                      missing_attr: 'AAAAA'
                    }
                  ],
                  transfers: [
                    {
                      city_from_id: city1.id,
                      city_to_id: city2.id,
                      links: [
                        {
                          id: nil,
                          url: 'https://google.com',
                          description: 'desc1'
                        },
                        {
                          id: nil,
                          url: 'https://rome2rio.com',
                          description: 'desc2'
                        }
                      ]
                    }
                  ],
                  hotel: {
                    name: 'new_hotel',
                    links: [
                      {
                        id: nil,
                        url: 'https://google2.com',
                        description: 'desc1'
                      }
                    ]
                  }
                }
              ]
        }
      end

      context 'and when there is trip' do
        context 'and when input params are valid' do
          let(:trip) { FactoryGirl.create :trip, users: [subject.current_user] }

          it 'updates trip and heads 200' do
            post 'create', params: days_params.merge(trip_id: trip.id),
                           format: :json
            expect(response).to have_http_status 200

            updated_day = trip.reload.days.first

            expect(updated_day.places.count).to eq(1)
            expect(updated_day.places.first.city_id).to eq(
              city2.id
            )
            expect(updated_day.transfers.count).to eq(1)
            expect(updated_day.transfers.first.city_from_id).to eq(
              city1.id
            )
            expect(updated_day.transfers.first.links.count).to eq(2)
            expect(updated_day.transfers.first.links.first.url).to eq(
              'https://google.com'
            )
            expect(updated_day.hotel.name).to eq('new_hotel')
            expect(updated_day.hotel.links.count).to eq(1)
            expect(updated_day.hotel.links.first.url).to eq(
              'https://google2.com'
            )
          end
        end

        context 'and when user is not included in trip' do
          let(:trip) { FactoryGirl.create :trip }

          it 'heads 403' do
            post 'create', params: days_params.merge(trip_id: trip.id),
                           format: :json
            expect(response).to have_http_status 403
          end
        end
      end

      context 'and when there is no trip' do
        let(:trip) { FactoryGirl.create :trip }

        it 'heads 404' do
          post 'create', params: days_params.merge(trip_id: 'no such trip'),
                         format: :json
          expect(response).to have_http_status 404
        end
      end
    end

    context 'when no logged user' do
      let(:trip) { FactoryGirl.create :trip }
      let(:day) { trip.days.first }
      let(:days_params) do
        {
          days:
              [
                {
                  id: day.id.to_s,
                  places: [
                    {
                      city_id: city2.id,
                      city_text: 'City',
                      missing_attr: 'AAAAA'
                    }
                  ]
                }
              ]
        }
      end
      it 'redirects to sign in' do
        post 'create', params: days_params.merge(trip_id: trip.id),
                       format: :json
        expect(response).to have_http_status 401
      end
    end
  end
end
