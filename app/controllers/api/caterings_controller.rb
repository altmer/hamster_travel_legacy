# frozen_string_literal: true

module Api
  class CateringsController < Api::BaseController
    before_action :find_trip
    before_action :authenticate_user!, only: [:update]
    before_action :authorize, only: [:update]
    before_action :api_authorize_readonly!, only: [:show]

    respond_to :json

    def show
      render json: {
        caterings: Views::CateringView.index_json(
          Trips::Caterings.list(@trip),
          current_user
        )
      }
    end

    def update
      ::Trips::Caterings.save(@trip, params_caterings[:caterings])
      render json: {
        res: true
      }
    end

    private

    def params_caterings
      params.require(:trip).permit(caterings:
      %i[
        id name description days_count persons_count
        amount_cents amount_currency
      ])
    end

    def find_trip
      @trip = ::Trips.by_id(params[:id])
    end

    def authorize
      head(403) && return unless @trip.include_user(current_user)
    end
  end
end
