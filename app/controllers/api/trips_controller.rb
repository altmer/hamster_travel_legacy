# frozen_string_literal: true

module Api
  class TripsController < Api::BaseController
    before_action :authenticate_user!, only: %i[
      upload_image delete_image destroy
    ]
    before_action :find_trip, only: %i[upload_image delete_image destroy]
    before_action :authorize, only: %i[upload_image delete_image]
    before_action :authorize_destroy, only: [:destroy]

    def index
      render json: Views::TripView.index_list_json(
        ::Trips.search(params[:term], current_user)
      )
    end

    def upload_image
      @trip.image = params[:file]
      @trip.image.name = 'photo.png'
      @trip.save
      render json: {
        status: 0,
        image_url: @trip.image_url_or_default
      }
    end

    def delete_image
      @trip.image = nil
      @trip.save
      render json: {
        status: 0,
        image_url: @trip.image_url_or_default
      }
    end

    def destroy
      @trip.archived = true
      @trip.save validate: false
      Travels::TripInvite.where(trip_id: @trip.id).destroy_all
      render json: { success: true }
    end

    private

    def find_trip
      @trip = ::Trips.by_id(params[:id])
    end

    def authorize
      return if @trip.include_user(current_user)
      render(json: { error: 'forbidden' }, status: 403)
    end

    def authorize_destroy
      return if @trip.author_user_id == current_user.id
      render(json: { error: 'forbidden' }, status: 403)
    end
  end
end
