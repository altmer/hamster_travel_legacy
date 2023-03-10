# frozen_string_literal: true

module Api
  class ReportsController < Api::BaseController
    respond_to :json

    before_action :find_trip
    before_action :authenticate_user!, only: [:update]
    before_action :authorize, only: [:update]
    before_action :api_authorize_readonly!, only: [:show]

    def show
      render json: {
        report: @trip.comment
      }
    end

    def update
      render json: {
        res: ::Trips.update_report(@trip, params[:report])
      }
    end

    private

    def authorize
      head(403) && return unless @trip.include_user(current_user)
    end

    def find_trip
      @trip = ::Trips.by_id(params[:id])
    end
  end
end
