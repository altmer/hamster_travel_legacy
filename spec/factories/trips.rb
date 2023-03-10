# frozen_string_literal: true

# == Schema Information
#
# Table name: trips
#
#  id                     :integer          not null, primary key
#  name                   :string
#  short_description      :text
#  start_date             :date
#  end_date               :date
#  archived               :boolean          default(FALSE)
#  comment                :text
#  budget_for             :integer          default(1)
#  private                :boolean          default(FALSE)
#  image_uid              :string
#  status_code            :string           default("0_draft")
#  author_user_id         :integer
#  updated_at             :datetime
#  created_at             :datetime
#  currency               :string
#  dates_unknown          :boolean          default(FALSE)
#  planned_days_count     :integer
#  countries_search_index :string
#

FactoryGirl.define do
  factory :trip, class: 'Travels::Trip' do
    sequence(:name) { |n| "Trip number #{n}" }
    short_description { 'short_description' }
    comment { 'some long report about the trip' }
    sequence(:start_date) { |n| Date.today - 2 + n }
    sequence(:end_date) { |n| Date.today + n }
    currency { 'RUB' }
    status_code { Trips::StatusCodes::DRAFT }
    dates_unknown { false }

    association :author_user, factory: :user

    trait :with_filled_days do
      after :create do |trip|
        city_from = FactoryGirl.create(:city)
        city_to = FactoryGirl.create(:city)
        trip.days.ordered.each_with_index do |day, i|
          day.comment = "Day #{i}"
          2.times do |index|
            day.transfers.create(
              build(:transfer, :with_data,
                    order_index: index, city_from_id: city_from.id,
                    city_to_id: city_to.id).attributes
            )
          end
          3.times do |index|
            day.activities.create(
              build(:activity, :with_data,
                    order_index: index, rating: (index % 3) + 1).attributes
            )
          end
          day.places.create(build(:place, city_id: city_to.id).attributes)
          day.hotel = Travels::Hotel.new(build(:hotel, :with_data).attributes)
          day.hotel.links = [FactoryGirl.build(:external_link)]
          day.expenses.destroy_all
          2.times do
            day.expenses.create(build(:expense, :with_data).attributes)
          end
          day.save validate: false
        end

        2.times do
          trip.caterings.create(build(:catering).attributes)
        end
      end
    end

    trait :with_transfers do
      after :create do |trip|
        trip.days.ordered.each do |day|
          day.transfers.create(build(:transfer, order_index: 0).attributes)
          day.transfers.create(
            build(:transfer, :with_data, order_index: 1).attributes
          )
          day.transfers.create(
            build(:transfer, :flight, order_index: 2).attributes
          )
        end
      end
    end

    trait :with_users do
      after :create do |trip|
        trip.users = create_list(:user, 2)
        trip.users << trip.author_user
        trip.save validate: false
      end
    end

    trait :with_invited do
      after :create do |trip|
        user = create(:user)
        Travels::TripInvite.create(
          trip: trip, inviting_user: trip.author_user, invited_user: user
        )
      end
    end

    trait :with_caterings do
      after :create do |trip|
        3.times do |index|
          trip.caterings.create(build(:catering, order_index: index).attributes)
        end
        trip.save validate: false
      end
    end

    trait :no_dates do
      start_date { nil }
      end_date { nil }
      dates_unknown { true }
      planned_days_count { 3 }
    end
  end

  factory :transfer, class: 'Travels::Transfer' do
    trait :with_data do
      city_from_id { create(:city).id }
      city_to_id { create(:city).id }

      amount_cents { rand(10_000) * 100 }
      amount_currency { 'RUB' }

      start_time(Date.today.beginning_of_day)
      end_time(Date.today.end_of_day)
    end

    trait :flight do
      city_from_id { create(:city).id }
      city_to_id { create(:city).id }

      amount_cents { rand(10_000) * 100 }
      amount_currency { 'RUB' }

      type { Travels::Transfer::Types::FLIGHT }

      code { 'HH404' }
      company { 'Hamster Airlines' }

      station_from { 'HAM' }
      station_to { 'FOO' }

      start_time(Date.today.beginning_of_day)
      end_time(Date.today.end_of_day)

      comment { 'very long comment' }
    end
  end

  factory :activity, class: 'Travels::Activity' do
    trait :with_data do
      sequence(:name) { |index| "Activity #{index}" }
      amount_cents { rand(10_000) * 100 }
      amount_currency { 'RUB' }
      comment { 'Activity comment' }
      link_description { 'Activity link description' }
      link_url { 'http://cool.site' }
    end
  end

  factory :place, class: 'Travels::Place' do
    trait :with_data do
      city_id { create(:city).id }
    end
  end

  factory :hotel, class: 'Travels::Hotel' do
    trait :with_data do
      name { 'Hotel' }
      amount_cents { rand(10_000) * 100 }
      amount_currency { 'RUB' }
      comment { 'Comment' }
    end
  end

  factory :expense, class: 'Travels::Expense' do
    trait :with_data do
      sequence(:name) { |n| "Day expense #{n}" }
      amount_cents { rand(10_000) * 100 }
      amount_currency { 'RUB' }
    end
  end

  factory :catering, class: 'Travels::Catering' do
    name { Faker::Address.city }

    description { Faker::Lorem.paragraph }

    amount_cents { rand(10_000) * 100 }
    amount_currency { 'RUB' }

    days_count(3)
    persons_count(2)
  end

  factory :document, class: 'Travels::Document' do
    name { 'My cat photo' }
    mime_type { 'image/jpeg' }

    before :create do |document|
      document.store(File.open("#{::Rails.root}/spec/fixtures/files/cat.jpg"))
    end
  end
end
