describe Api::DaysController do

  describe '#index' do
    let(:trip) {FactoryGirl.create(:trip)}

    context 'when user is logged in' do
      login_user

      context 'and when there is trip' do
        it 'returns trip days as JSON' do
          get 'index', trip_id: trip.id.to_s, format: :json
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)
          expect(json.count).to eq(8)
          expect(json.first['date']).to eq(I18n.l(trip.start_date, format: '%d.%m.%Y %A'))
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
        json = JSON.parse(response.body)
        expect(json.count).to eq(8)
        expect(json.first['date']).to eq(I18n.l(trip.start_date, format: '%d.%m.%Y %A'))
      end
    end
  end

  describe '#create' do
    let(:trip_without_user) {FactoryGirl.create :trip}
    let(:trip) {FactoryGirl.create :trip, users: [subject.current_user]}
    let(:day) {trip.days.first}
    let(:days_params) { { days: {'1' => {id: day.id.to_s, comment: 'new_day_comment', add_price: 12345} } } }

    context 'when user is logged in' do
      login_user

      context 'and when there is trip' do

        context 'and when input params are valid' do
          it 'updates trip and heads 200' do
            post 'create', days_params.merge(trip_id: trip.id), format: :json
            expect(response).to have_http_status 200
            updated_day = trip.reload.days.first
            expect(updated_day.comment).to eq 'new_day_comment'
            expect(updated_day.add_price).to eq 12345
          end
        end

        context 'and when user is not included in trip' do
          it 'heads 403' do
            post 'create', days_params.merge(trip_id: trip_without_user.id), format: :json
            expect(response).to have_http_status 403
          end
        end

      end

      context 'and when there is no trip' do
        it 'heads 404' do
          post 'create', days_params.merge(trip_id: 'no such trip'), format: :json
          expect(response).to have_http_status 404
        end
      end

    end

    context 'when no logged user' do
      it 'redirects to sign in' do
        post 'create', days_params.merge(trip_id: trip.id), format: :json
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end


end