module Supercharged::ChargesHelper
  # No order id while generating form. It will be added later via JS
  # JS finds order input by this fake id because id and name will be integration specific
  FAKE_ORDER_ID = "[payment_order_id]"

  DEFAULT_AMOUNT_FIELD_OPTIONS = {
    role: "charge-amount",
    required: true,
    min: 0
  }

  def charge_form_for(service_name, options = {}, &block)
    raise ArgumentError, "Missing block" unless block_given?

    default_options = {service: service_name}
    options.merge!(default_options)

    options = with_default_html_options(options)

    account = options.delete(:account)
    notify_url = gateways_result_url(service_name)

    payment_service_for(FAKE_ORDER_ID, account, options) do |service|
      service.notify_url notify_url
      block.call(service)
    end
  end

  def charge_form_amount_field(service, options = {})
    amount_field_name = service.mappings[:amount] || raise("Undefined amount field mapping")

    options = options.merge(DEFAULT_AMOUNT_FIELD_OPTIONS)

    number_field_tag amount_field_name, nil, options
  end

  private

  def with_default_html_options(options)
    options[:html] ||= {}
    options[:html].merge!(role: "gateway-charge-form")
    options
  end

end
