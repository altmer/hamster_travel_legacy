# frozen_string_literal: true

module Api
  class TransfersController < Api::BaseController
    before_action :find_trip
    before_action :find_day
    before_action :authenticate_user!, only: [:create]
    before_action :authorize, only: [:create]
    before_action :api_authorize_readonly!, only: %i[
      index previous_place previous_hotel
    ]

    def index
      render json: Views::DayView.show_json(
        @day,
        %i[transfers hotel places],
        current_user
      )
    end

    def create
      Trips::Days.update_day(@trip, @day, day_params)
      render json: { status: 0 }
    end

    def previous_place
      previous_day = Trips::Days.previous_day(@trip, @day)
      head(404) && return if previous_day.blank?
      render json: {
        place: Views::PlaceView.show_json(
          Trips::Places.last_place(previous_day)
        )
      }
    end

    def previous_hotel
      previous_day = Trips::Days.previous_day(@trip, @day)
      head(404) && return if previous_day.blank?
      render json: {
        hotel: Views::HotelView.show_json(
          Trips::Hotels.by_day(previous_day)
        )
      }
    end

    private

    # rubocop:disable MethodLength
    def day_params
      params.require(:day).permit(
        transfers: [
          :id, :type, :code, :company, :station_from, :station_to, :start_time,
          :end_time, :comment, :amount_cents, :amount_currency, :city_to_id,
          :city_from_id, { links: %i[id url description] }
        ],
        hotel: [
          :id, :name, :comment, :amount_cents, :amount_currency,
          { links: %i[id url description] }
        ],
        places: %i[
          id city_id
        ]
      )
    end

    def authorize
      head(403) && return unless @trip.include_user(current_user)
    end

    def find_trip
      @trip = Trips.by_id(params[:trip_id])
    end

    def find_day
      @day = Trips::Days.by_id(@trip, params[:day_id])
    end
  end
end
