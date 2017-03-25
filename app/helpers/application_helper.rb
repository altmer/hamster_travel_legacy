# frozen_string_literal: true
module ApplicationHelper
  def currency_symbol(currency = nil)
    currency ||= current_user&.currency
    currency ||= CurrencyHelper::DEFAULT_CURRENCY
    currency = Money::Currency.find(currency)
    currency.try(:symbol)
  end

  def default_currency_hash(trip, user)
    "amount_currency_text: '#{default_currency_text_for_trip(trip, user)}'," \
    " amount_currency: '#{default_currency_for_trip(trip, user)}'"
  end

  def default_currency_for_trip(trip, user)
    trip.currency || user.try(:currency) || CurrencyHelper::DEFAULT_CURRENCY
  end

  def default_currency_text_for_trip(trip, user)
    Money::Currency.find(default_currency_for_trip(trip, user))&.symbol
  end

  def error_messages!(object)
    return '' if object.errors.empty?

    messages = object.errors.full_messages.map do |msg|
      content_tag(:li, msg)
    end.join
    sentence = I18n.t('errors.messages.not_saved')

    html = <<-HTML
    <div class="alert alert-danger">
      <button class='close' data-dismiss='alert'>&times;</button>
      <h4>#{sentence}</h4>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def datepicker_options(model_name, record = nil)
    res = {
      'ng-model' => model_name, 'data-provide' => 'datepicker',
      'data-placement' => 'bottom', 'data-date-format' => 'dd.mm.yyyy',
      'data-date-week-start' => 1, 'data-date-autoclose' => true,
      'data-date-language' => I18n.locale, 'data-date-start-view' => 'day',
      'autocomplete' => 'off'
    }
    unless record.blank? || record.send(model_name).blank?
      res['ng-init'] = "#{model_name}='#{record.send(model_name)}'"
    end
    res
  end

  def trip_status_class(status_code)
    {
      Travels::Trip::StatusCodes::DRAFT => 'bg-draft',
      Travels::Trip::StatusCodes::PLANNED => 'bg-planned',
      Travels::Trip::StatusCodes::FINISHED => 'bg-finished'
    }[status_code]
  end

  def trip_period(trip, original_trip)
    original_trip.blank? ? trip.last_non_empty_day_index : original_trip.period
  end

  def trip_status_options
    Travels::Trip::StatusCodes::OPTIONS.map do |option|
      [I18n.t(option[0]), option[1]]
    end
  end

  def transfer_type_options
    Travels::Transfer::Types::OPTIONS.map do |option|
      [I18n.t(option[0]), option[1]]
    end
  end

  def trip_start_date(trip)
    (l trip.start_date, format: :month).html_safe if trip.start_date.present?
  end

  def flag_with_title(country, size = 16)
    return '' if country.blank?
    country_code = country.country_code
    "<img src='#{flag_url(country_code, size)}' class='flag flag-#{size}'" \
    " title='#{country&.name}' />".html_safe
  end

  def flag(country_code, size = 16)
    return '' if country_code.blank?
    "<img src='#{flag_url(country_code, size)}'" \
    " class='flag flag-#{size}'/>".html_safe
  end

  def flag_url(country_code, size)
    "#{Settings.images.base_url}/#{Settings.images.flags_folder}" \
    "/#{size}/#{country_code.downcase}.png"
  end

  def days_count(trip)
    "#{trip.days_count}&nbsp;" \
    "#{I18n.t('common.days', count: trip.days_count)}".html_safe
  end

  def trip_dates(trip)
    if trip.start_date.present? && trip.end_date.present?
      res = if trip.start_date == trip.end_date
              trip.start_date.to_s
            else
              "#{trip.start_date} - #{trip.end_date}"
            end
      res += " (#{days_count(trip)})"
    else
      res = days_count(trip)
    end
    res.html_safe
  end
end
