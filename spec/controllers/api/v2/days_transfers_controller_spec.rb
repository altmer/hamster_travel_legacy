describe Api::V2::DaysTransfersController do
  describe '#index' do
    let(:trip) {FactoryGirl.create(:trip, :with_filled_days)}

    context 'when user is logged in' do
      login_user

      context 'and when there is trip' do
        it 'returns trip days as JSON' do
          get 'index', trip_id: trip.id.to_s, format: :json
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)['days']
          expect(json.count).to eq(8)
          expect(json.first['date']).to eq(I18n.l(trip.start_date, format: '%d.%m.%Y %A'))
          expect(json.first['transfers'].count).to eq(trip.days.first.transfers.count)
          expect(json.first['activities']).to be_nil
        end
      end

      context 'and when there is no trip' do
        it 'heads 404' do
          get 'index', trip_id: 'no_trip', format: :json
          expect(response).to have_http_status 404
        end
      end

    end

    context 'when no logged user' do
      it 'behaves the same' do
        get 'index', trip_id: trip.id.to_s, format: :json
        expect(response).to have_http_status 200
        json = JSON.parse(response.body)['days']
        expect(json.count).to eq(8)
        expect(json.first['date']).to eq(I18n.l(trip.start_date, format: '%d.%m.%Y %A'))
      end
    end
  end

end