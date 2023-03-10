# frozen_string_literal: true

class ApplicationController < ActionController::Base
  CACHE_RATES = "#{Rails.root}/lib/ecb_rates.xml"

  layout 'main'

  before_action :store_current_location, unless: :devise_controller?
  def store_current_location
    return unless request.get?
    return if request.url.include?('/api/')
    store_location_for(:user, request.url)
  end

  before_action :set_locale
  def set_locale
    I18n.locale = params[:locale] ||
                  current_user.try(:locale) ||
                  I18n.default_locale
  end

  before_action :load_exchange_rates
  def load_exchange_rates
    @bank = Money.default_bank
    return if exchange_rates_updated?
    update_exchange_rates!
  end

  def exchange_rates_updated?
    @bank.rates_updated_at && @bank.rates_updated_at > Time.now - 1.days
  end

  def update_exchange_rates!
    rates = ExchangeRate.current
    if rates
      @bank.update_rates_from_s(rates.eu_file)
    else
      @bank.update_rates(CACHE_RATES)
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  after_action :set_csrf_cookie_for_ng

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def default_url_options(_options = {})
    { locale: I18n.locale }
  end

  before_action :configure_permitted_parameters, if: :devise_controller?
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: %i[first_name last_name email]
    )
  end

  def no_access
    redirect_to('/errors/no_access', locale: params[:locale])
  end

  def not_found
    redirect_to('/errors/not_found', locale: params[:locale])
  end

  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || request.referer || root_path
  end

  rescue_from ActiveRecord::RecordNotFound do
    not_found
  end
end
