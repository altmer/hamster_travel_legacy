describe Api::CitiesController do

  describe '#index' do

    def check_city json_hash, city
      expect(json_hash).to eq({"name" => city.name, "text" => city.translated_text,
                                "code" => city.id, 'flag_image' => ApplicationController.helpers.flag(city.country_code)})
    end

    def check_cities body, term
      cities = Geo::City.find_by_term(term).page(1).to_a
      json = JSON.parse(body)
      check_city(json.first, cities.first)
      expect(json.count).to eq cities.count
    end

    context 'when user is logged in' do
      login_user
      after(:each) { Rails.cache.clear }

      it 'responds with empty array if term is shorter than 3 letters' do
        get 'index', term: 'ci', format: :json
        expect(response).to have_http_status 200
        expect(JSON.parse(response.body)).to eq []
      end

      it 'responds with empty array if term is blank' do
        get 'index', format: :json
        expect(response).to have_http_status 200
        expect(JSON.parse(response.body)).to eq []
      end

      it 'responds with cities when something found by english name' do
        term = 'city'
        get 'index', term: term, format: :json
        expect(response).to have_http_status 200
        check_cities response.body, term
      end

      it 'responds with cities when something found by russian name' do
        term = 'город'
        get 'index', term: term, format: :json
        expect(response).to have_http_status 200
        check_cities response.body, term
      end

      it 'responds with empty array if nothing found' do
        get 'index', term: 'capital', format: :json
        expect(response).to have_http_status 200
        expect(JSON.parse(response.body)).to eq []
      end

      context 'when requested empty term' do
        let (:term) { '[$empty$]' }

        it 'returns user\'s home city' do
          get 'index', term: term, format: :json
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)
          expect(json.count).to eq(1)
          check_city(json.first, subject.current_user.home_town)
        end

        context 'when passed trip_id' do
          let (:term) { '[$empty$]' }
          let (:trip) { FactoryGirl.create(:trip, :with_filled_days) }

          it 'returns user\'s home city and all cities from trip' do
            get 'index', term: term, trip_id: trip.id, format: :json
            expect(response).to have_http_status 200
            json = JSON.parse(response.body)
            expect(json.count).to eq(2)
            check_city(json.first, subject.current_user.home_town)
            check_city(json.last, trip.visited_cities.first)
          end

        end
      end
    end

    context 'when no logged user' do
      it 'behaves the same as for logged user' do
        term = 'city'
        get 'index', term: term, format: :json
        expect(response).to have_http_status 200
        check_cities response.body, term
      end

      context 'when requested empty term' do
        it 'returns empty array' do
          term = '[$empty$]'
          get 'index', term: term, format: :json
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)
          expect(json.count).to eq(0)
        end
      end
    end
  end

end