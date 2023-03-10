# frozen_string_literal: true

module Api
  class ParticipantsController < Api::BaseController
    before_action :find_trip
    before_action :api_authorize_readonly!, only: [:index]

    def index
      render json: {
        users: collect_users(@trip.users),
        invited_users: collect_users(@trip.invited_users)
      }
    end

    private

    def find_trip
      @trip = ::Trips.by_id(params[:id])
    end

    def collect_users(users)
      users.collect do |user|
        {
          id: user.id.to_s,
          photo_url: user.image_url,
          name: user.full_name,
          initials: user.initials,
          color: user.background_color
        }
      end
    end
  end
end
