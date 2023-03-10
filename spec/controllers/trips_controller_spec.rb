# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TripsController do
  let(:user) { FactoryGirl.create(:user) }

  let(:attrs) { FactoryGirl.build(:trip).attributes.with_indifferent_access }
  let(:attrs_no_dates) do
    FactoryGirl.build(:trip, :no_dates).attributes.with_indifferent_access
  end

  describe '#index' do
    context 'when user is logged in' do
      before { login_user(user) }

      it 'shows trips index page, all trips that are not draft' do
        expect(::Trips).to receive(:list).with('2').and_return(
          Travels::Trip.relevant
        )
        get 'index', params: { page: 2 }
        expect(response).to be_success
      end
    end

    context 'when no logged user' do
      it 'still shows trips index page' do
        expect(::Trips).to receive(:list).with(nil).and_return(
          Travels::Trip.relevant
        )
        get 'index'
        expect(response).to be_success
      end
    end
  end

  describe '#my' do
    context 'when user is logged in' do
      before { login_user(user) }

      it 'shows user plans' do
        expect(UserTrips).to receive(:list_trips).with(
          subject.current_user,
          '1'
        ).and_return(Travels::Trip.all)
        get 'my', params: { page: 1 }
        expect(response).to be_success
      end
    end

    context 'when no logged user' do
      it 'responds with not auhorized' do
        get 'my'
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#drafts' do
    context 'when user is logged in' do
      before { login_user(user) }

      it 'shows user drafts' do
        expect(UserTrips).to receive(:list_drafts).with(
          subject.current_user, '1'
        ).and_return(Travels::Trip.all)
        get 'drafts', params: { page: 1 }
        expect(response).to be_success
      end
    end

    context 'when no logged user' do
      it 'responds with not auhorized' do
        get 'drafts'
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#new' do
    context 'when user is logged in' do
      before { login_user(user) }

      it 'renders form with new trip' do
        get 'new'
        expect(response).to be_success
      end

      context 'when parameter copy from present' do
        context 'and when it is valid existing trip id' do
          let(:trip) do
            FactoryGirl.create(
              :trip,
              currency: 'USD',
              status_code: Trips::StatusCodes::PLANNED
            )
          end

          it 'renders template with new trip copied from old trip' do
            get 'new', params: { copy_from: trip.id }
            expect(response).to be_success
          end
        end

        context 'and when trying to copy private trip' do
          let(:trip_private) { FactoryGirl.create(:trip, private: true) }
          it 'just creates new trip' do
            get 'new', params: { copy_from: trip_private.id }
            expect(response).to be_success
          end
        end

        context 'and when it is not valid' do
          it 'redirects to not found' do
            get 'new', params: { copy_from: 'blahblah' }
            expect(response).to redirect_to '/errors/not_found'
          end
        end
      end
    end

    context 'when no logged user' do
      it 'respond with not authorized status' do
        get 'new'
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#create' do
    context 'when user is logged in' do
      before { login_user(user) }

      context 'and when trip is valid' do
        let(:params) { { travels_trip: attrs.merge(currency: 'INR') } }

        it 'creates new trip and redirects to show' do
          post 'create', params: params
          expect(Travels::Trip.count).to eq(1)
          trip = Travels::Trip.first
          expect(response).to redirect_to trip_path(trip)
          expect(trip).to be_persisted
          expect(trip.author_user).to eq subject.current_user
          expect(trip.users).to eq [subject.current_user]
          expect(trip.name).to eq params[:travels_trip]['name']
          expect(trip.short_description).to eq(
            params[:travels_trip]['short_description']
          )
          expect(trip.start_date).to eq params[:travels_trip]['start_date']
          expect(trip.end_date).to eq params[:travels_trip]['end_date']
          expect(trip.currency).to eq('INR')
          days = Trips::Days.list(trip)
          first_day = days.first
          hotel = Trips::Hotels.by_day(first_day)
          expect(hotel.amount_currency).to eq('INR')
        end

        context 'and when trip is without dates' do
          let(:params) { { travels_trip: attrs_no_dates } }

          it 'creates new trip and redirects to show' do
            post 'create', params: params
            expect(Travels::Trip.count).to eq(1)
            trip = Travels::Trip.first
            expect(trip).to be_persisted
            expect(response).to redirect_to trip_path(trip)

            expect(trip.author_user).to eq subject.current_user
            expect(trip.users).to eq [subject.current_user]
            expect(trip.name).to eq params[:travels_trip]['name']
            expect(trip.short_description).to eq(
              params[:travels_trip]['short_description']
            )
            expect(trip.start_date).to eq nil
            expect(trip.end_date).to eq nil
            expect(trip.days_count).to eq 3
            expect(trip.planned_days_count).to eq 3
            expect(trip.currency).to eq('RUB')
          end
        end

        context 'and when trip is copied from original' do
          let(:original) { FactoryGirl.create(:trip, :with_filled_days) }
          let(:original_days) { Trips::Days.list(original) }
          let(:original_first_day) { original_days.first }
          let(:original_first_day_transfers) do
            Trips::Transfers.list(original_first_day)
          end
          let(:original_first_day_first_transfer) do
            original_first_day_transfers.first
          end
          let(:original_first_day_places) do
            Trips::Places.list(original_first_day)
          end
          let(:original_first_day_hotel) do
            Trips::Hotels.by_day(original_first_day)
          end
          let(:original_last_day) { original_days.last }

          let(:original_private) do
            FactoryGirl.create(:trip, :with_filled_days, private: true)
          end

          context 'and when it is valid existing trip id' do
            it 'renders template with new trip copied from old trip' do
              post 'create', params: params.merge(copy_from: original.id)
              expect(Travels::Trip.count).to eq(2)
              trip = Travels::Trip.all.order(created_at: :desc).first
              days = Trips::Days.list(trip)
              first_day = days.first
              first_day_transfers = Trips::Transfers.list(first_day)
              first_day_places = Trips::Places.list(first_day)
              first_day_hotel = Trips::Hotels.by_day(first_day)
              last_day = days.last

              expect(trip.comment).to be_nil
              expect(days.count).to eq(original_days.count)

              expect(first_day.comment).to eq(
                original_first_day.comment
              )
              expect(first_day.date_when).to eq(
                params[:travels_trip]['start_date']
              )
              expect(first_day_transfers.count).to eq(
                original_first_day_transfers.count
              )
              expect(first_day_transfers.first.amount).to eq(
                original_first_day_transfers.first.amount
              )

              expect(first_day_places.count).to eq(
                original_first_day_places.count
              )
              expect(first_day_hotel.name).to eq(
                original_first_day_hotel.name
              )

              expect(last_day.comment).to eq(
                original_last_day.comment
              )
              expect(last_day.date_when).to eq(
                params[:travels_trip]['end_date']
              )

              expect(trip.caterings.count).to eq(original.caterings.count)
              new_names_caterings = trip.caterings.map(&:name).sort
              old_names_caterings = original.caterings.map(&:name).sort
              expect(new_names_caterings).to eq(old_names_caterings)
            end
          end

          context 'and when trying to copy private trip' do
            it 'just creates new trip' do
              post 'create',
                   params: params.merge(copy_from: original_private.id)

              expect(Travels::Trip.count).to eq(2)
              trip = Travels::Trip.all.order(created_at: :desc).first
              days = Trips::Days.list(trip)
              first_day = days.first
              last_day = days.last

              expect(first_day.comment).to be_nil
              expect(first_day.date_when).to eq(
                params[:travels_trip]['start_date']
              )
              expect(first_day.transfers.count).to eq 0

              expect(last_day.comment).to be_nil
              expect(last_day.date_when).to eq(
                params[:travels_trip]['end_date']
              )
            end
          end

          context 'and when it is not valid' do
            it 'renders template with new trip' do
              post 'create', params: params.merge(copy_from: 'fdsfdsfdfds')
              expect(response).to redirect_to '/errors/not_found'
              expect(Travels::Trip.count).to eq(0)
            end
          end

          context 'and when it has more days than original trip' do
            it 'renders template with new trip' do
              ps = params.merge(copy_from: original.id)
              ps[:travels_trip]['end_date'] += 1.day

              post 'create', params: ps
              expect(Travels::Trip.count).to eq(2)
              trip = Travels::Trip.all.order(created_at: :desc).first
              days = Trips::Days.list(trip)
              first_day = days.first
              first_day_transfers = Trips::Transfers.list(first_day)
              first_day_first_transfer = first_day_transfers.first
              last_day = days.last

              expect(trip.start_date).to eq(ps[:travels_trip]['start_date'])
              expect(trip.end_date).to eq(ps[:travels_trip]['end_date'])

              expect(first_day.comment).to eq(
                original_first_day.comment
              )
              expect(first_day.date_when).to eq(
                params[:travels_trip]['start_date']
              )
              expect(first_day_transfers.count).to eq(
                original_first_day_transfers.count
              )
              expect(first_day_first_transfer.amount).to eq(
                original_first_day_first_transfer.amount
              )

              expect(last_day.comment).to be_nil
              expect(last_day.date_when).to eq(
                params[:travels_trip]['end_date']
              )
            end
          end

          context 'and when it has less days than original trip' do
            it 'renders template with new trip' do
              ps = params.merge(copy_from: original.id)
              ps[:travels_trip]['end_date'] -= 1.day

              post 'create', params: ps
              expect(Travels::Trip.count).to eq(2)
              trip = Travels::Trip.all.order(created_at: :desc).first
              days = Trips::Days.list(trip)
              first_day = days.first
              first_day_transfers = Trips::Transfers.list(first_day)
              first_day_first_transfer = first_day_transfers.first
              last_day = days.last

              expect(first_day.comment).to eq(
                original_first_day.comment
              )
              expect(first_day.date_when).to eq(
                params[:travels_trip]['start_date']
              )
              expect(first_day_transfers.count).to eq(
                original_first_day_transfers.count
              )
              expect(first_day_first_transfer.amount).to eq(
                original_first_day_first_transfer.amount
              )

              expect(last_day.comment).to eq(
                original_days[-2].comment
              )
              expect(last_day.date_when).to eq(
                params[:travels_trip]['end_date']
              )
            end
          end
        end
      end

      context 'and when trip is valid with forbidden attribute' do
        let(:params) { { travels_trip: attrs.merge(archived: true) } }

        it 'creates new trip and redirects to show' do
          post 'create', params: params
          expect(Travels::Trip.count).to eq(1)
          trip = Travels::Trip.first
          expect(trip).to be_persisted
          expect(trip.name).to eq params[:travels_trip]['name']
          expect(trip.archived).to be false
          expect(response).to redirect_to(trip_path(trip))
        end
      end

      context 'and when trip is not valid' do
        let(:params) { { travels_trip: attrs.reject { |k, _| k == 'name' } } }

        it 'renders new' do
          post 'create', params: params
          expect(Travels::Trip.count).to eq(0)
          expect(response).to have_http_status(200)
        end
      end
    end

    context 'when no logged user' do
      let(:params) { { travels_trip: attrs } }

      it 'redirects to sign in' do
        post 'create', params: params
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#edit' do
    context 'when user is logged in' do
      before { login_user(user) }

      context 'and when user is included in this trip' do
        let(:trip) { FactoryGirl.create(:trip, users: [subject.current_user]) }

        it 'renders edit template' do
          get 'edit', params: { id: trip.id }
          expect(response).to be_success
        end
      end

      context 'and when user is not included in this trip' do
        let(:trip) do
          FactoryGirl.create(:trip, author_user: subject.current_user)
        end

        it 'redirects to dashboard with flash' do
          get 'edit', params: { id: trip.id }
          expect(response).to redirect_to '/errors/no_access'
        end
      end

      context 'and when trip does not exist' do
        it 'heads code 404' do
          get 'edit', params: { id: 'not-existing-id' }
          expect(response).to redirect_to '/errors/not_found'
        end
      end
    end

    context 'when no logged user' do
      let(:trip) { FactoryGirl.create(:trip) }

      it 'redirects to sign in' do
        get 'edit', params: { id: trip.id }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#update' do
    let(:update_attrs) do
      {
        travels_trip: attrs.merge(
          name: 'New Updated Name',
          status_code: Trips::StatusCodes::PLANNED,
          private: true, currency: 'EUR'
        ),
        id: trip.id
      }
    end

    context 'when user is logged in' do
      before { login_user(user) }

      context 'and when user is included in this trip' do
        let(:trip) { FactoryGirl.create(:trip, users: [subject.current_user]) }

        context 'and when params are valid' do
          it 'updates trip and redirects to show with notice' do
            put 'update', params: update_attrs
            trip_updated = Travels::Trip.find(trip.id)
            expect(trip_updated.name).to eq 'New Updated Name'
            expect(trip_updated.status_code).to eq(
              Trips::StatusCodes::PLANNED
            )
            expect(trip_updated.private).to eq true
            expect(trip_updated.currency).to eq('EUR')
            expect(response).to redirect_to trip_path(trip)
            expect(flash[:notice]).to eq I18n.t('common.update_successful')
          end

          context 'when number of days changes' do
            let(:update_attrs) do
              {
                travels_trip: attrs.merge(
                  name: 'New Updated Name',
                  start_date: Date.today, end_date: Date.today + 1.day,
                  status_code: Trips::StatusCodes::PLANNED,
                  private: true, currency: 'EUR'
                ),
                id: trip.id
              }
            end

            context 'when there is one catering' do
              let(:trip) do
                FactoryGirl.create(
                  :trip, :with_filled_days, users: [subject.current_user]
                )
              end

              it 'updates catering days accordingly' do
                trip.caterings = [FactoryGirl.build(:catering)]
                trip.save

                put 'update', params: update_attrs
                trip_updated = Travels::Trip.find(trip.id)
                expect(trip_updated.name).to eq 'New Updated Name'
                expect(trip_updated.status_code).to eq(
                  Trips::StatusCodes::PLANNED
                )
                expect(trip_updated.private).to eq true

                expect(trip_updated.start_date).to eq(Date.today)
                expect(trip_updated.end_date).to eq(Date.today + 1.day)
                expect(trip_updated.caterings.first.days_count).to eq(2)
              end
            end
          end
        end

        context 'and when params are not valid' do
          let(:update_attrs_invalid) do
            {
              travels_trip: attrs.merge('name' => nil),
              id: trip.id
            }
          end

          it 'renders edit template' do
            put 'update', params: update_attrs_invalid
            trip_updated = Travels::Trip.find(trip.id)
            expect(trip_updated.name).to eq(trip.name)
            expect(trip_updated.status_code).not_to eq(
              Trips::StatusCodes::PLANNED
            )
          end
        end
      end

      context 'and when user is not included in this trip' do
        let(:trip) do
          FactoryGirl.create(:trip, author_user: subject.current_user)
        end

        it 'redirects to dashboard with flash' do
          put 'update', params: update_attrs
          expect(response).to redirect_to '/errors/no_access'
          trip_updated = Travels::Trip.find(trip.id)
          expect(trip_updated.name).to eq(trip.name)
          expect(trip_updated.status_code).not_to eq(
            Trips::StatusCodes::PLANNED
          )
        end
      end
    end

    context 'when no logged user' do
      let(:trip) { FactoryGirl.create(:trip) }

      it 'redirects to sign in' do
        put 'update', params: update_attrs
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#show' do
    context 'when user is logged in' do
      before { login_user(user) }

      context 'and when trip exists' do
        context 'and when trip is not private' do
          let(:trip) { FactoryGirl.create(:trip) }

          it 'renders show template' do
            get 'show', params: { id: trip.id }
            expect(response).to be_success
          end

          let(:filled_trip) do
            FactoryGirl.create(:trip, :with_filled_days, :with_caterings)
          end

          it 'renders docx' do
            get 'show', params: { id: filled_trip.id, format: :docx }
            expect(response).to have_http_status 200
          end
        end

        context 'and when trip is private' do
          let(:trip) { FactoryGirl.create(:trip, private: true) }

          it 'redirects to dashboard with flash' do
            get 'show', params: { id: trip.id }
            expect(response).to redirect_to '/errors/no_access'
          end
        end

        context 'and when trip is private but current user is a participant' do
          let(:trip) do
            FactoryGirl.create(:trip, private: true,
                                      users: [subject.current_user])
          end

          it 'renders show template' do
            get 'show', params: { id: trip.id }
            expect(response).to have_http_status 200
          end
        end
      end

      context 'and when trip does not exist' do
        it 'renders show template' do
          get 'show', params: { id: 'non-existing-id' }
          expect(response).to redirect_to '/errors/not_found'
        end
      end
    end

    context 'when no logged user' do
      context 'and when trip is not private' do
        let(:trip) { FactoryGirl.create(:trip) }

        it 'renders show template' do
          get 'show', params: { id: trip.id }
          expect(response).to have_http_status 200
        end
      end

      context 'and when trip is private' do
        let(:trip) { FactoryGirl.create(:trip, private: true) }

        it 'redirects to dashboard with flash' do
          get 'show', params: { id: trip.id }
          expect(response).to redirect_to '/errors/no_access'
        end
      end
    end
  end
end
