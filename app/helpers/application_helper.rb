module ApplicationHelper
  TAB_PLAN = 'plan'
  TAB_REPORT = 'report'
  TAB_PLAN_ACTIVITIES = 'plan_activities'
  TAB_CATERING = 'catering'

  def currency_symbol currency = nil
    currency = (current_user.try(:currency) || CurrencyHelper::DEFAULT_CURRENCY) if currency.blank?
    currency = Money::Currency.find(currency)
    currency.try(:symbol)
  end

  def default_currency_hash trip, user
    "amount_currency_text: '#{default_currency_text_for_trip(trip, user)}', amount_currency: '#{default_currency_for_trip(trip, user)}'"
  end

  def default_currency_for_trip trip, user
    trip.currency || user.try(:currency) || CurrencyHelper::DEFAULT_CURRENCY
  end

  def default_currency_text_for_trip trip, user
    currency = default_currency_for_trip(trip, user)
    currency = Money::Currency.find(currency)
    currency.try(:symbol)
  end

  def exchange_money from, to, amount
    Money.new(amount * 100, from).exchange_to(to)
  end

  def error_messages! (object)
    return '' if object.errors.empty?

    messages = object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
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
        'ng-model' => model_name,
        'data-provide' => 'datepicker',
        'data-placement' => 'bottom',
        'data-date-format' => 'dd.mm.yyyy',
        'data-date-week-start' => 1,
        'data-date-autoclose' => true,
        'data-date-language' => I18n.locale,
        'data-date-start-view' => 'day',
        'autocomplete' => 'off'
    }
    res.merge!('ng-init' => "#{model_name}='#{record.send(model_name)}'") unless record.blank? or
        record.send(model_name).blank?
    res
  end

  def trip_status_class status_code
    {
        Travels::Trip::StatusCodes::DRAFT => 'bg-draft',
        Travels::Trip::StatusCodes::PLANNED => 'bg-planned',
        Travels::Trip::StatusCodes::FINISHED => 'bg-finished'
    }[status_code]
  end

  def trip_period trip, original_trip
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

  def trip_start_date trip
    (l trip.start_date, format: :month).html_safe if trip.start_date.present?
  end

  def flag country_code, size = 16, with_tooltip = false
    return '' if country_code.blank?
    url = "#{Settings.images.base_url}/#{Settings.images.flags_folder}/#{size}/#{country_code.downcase}.png"
    tooltip_attrs = nil
    if with_tooltip
      country = Geo::Country.send(country_code)
      tooltip_attrs = "uib-tooltip='#{country.try(:name)}' tooltip-placement='bottom'"
    end
    "<img src='#{url}' class='flag flag-#{size}' #{tooltip_attrs} />".html_safe
  end

  def days_count trip
    "#{trip.days_count}&nbsp;#{I18n.t('common.days', count: trip.days_count)}".html_safe
  end

  def trip_dates trip
    if trip.start_date.present? && trip.end_date.present?
      if trip.start_date == trip.end_date
        res = "#{trip.start_date}"
      else
        res = "#{trip.start_date} - #{trip.end_date}"
      end

      res += " (#{days_count(trip)})"
    else
      res = days_count(trip)
    end
    res.html_safe
  end

end
