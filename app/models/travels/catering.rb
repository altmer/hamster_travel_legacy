# == Schema Information
#
# Table name: caterings
#
#  id              :integer          not null, primary key
#  city_code       :string
#  city_text       :string
#  description     :text
#  days_count      :integer
#  persons_count   :integer
#  trip_id         :integer
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("RUB"), not null
#  order_index     :integer
#

module Travels
  class Catering < ActiveRecord::Base
    include Concerns::Ordered
    include Concerns::Copyable

    EXPENSES = ['breakfast', 'lunch', 'dinner', 'coffee', 'main_course']

    belongs_to :trip, class_name: 'Travels::Trip'

    has_many :expenses, :class_name => 'Travels::Expense', as: :expendable

    monetize :amount_cents

    def as_json(*args)
      json = super(except: [:_id])
      json['id'] = id.to_s
      json['amount_cents'] = amount_cents / 100
      json['amount_currency_text'] = amount.currency.symbol
      json['expenses'] = expenses.as_json(args)
      json
    end

    def self.default_expenses currency
      EXPENSES.each_with_index.map do |exp, index|
        Travels::Expense.new(amount_currency: currency, name: I18n.t("trips.expenses.#{exp}"), id: Time.now.to_i + index)
      end
    end

  end
end