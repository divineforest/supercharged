require 'active_merchant'

class GatewayNotification < ActiveRecord::Base
  belongs_to :charge

  serialize :params

  before_create :set_charge_id

  attr_accessor :raw_post, :logger

  def acknowledge
    adapter.acknowledge
  end

  def complete?
    adapter.complete?
  end

  def need_response?
    adapter.respond_to?(:success_response)
  end

  def success_response
    adapter.respond_to?(:success_response) ? adapter.success_response : "OK"
  end

  def approve
    logger.info "real amount = #{real_amount}"
    charge.approve(real_amount) unless charge.ok?
  end

  def real_amount
    params[service.mappings[:amount]]
  end

  private

  def adapter
    @adapter ||= "ActiveMerchant::Billing::Integrations::#{gateway.classify}::Notification".classify.constantize.new(raw_post)
  rescue NameError
    raise "Unknown integration '#{gateway}'"
  end

  def service
    "ActiveMerchant::Billing::Integrations::#{gateway.classify}::Helper".classify.constantize
  end

  def set_charge_id
    self.charge_id = adapter.item_id || raise("Undefined charge_id")
  end

end
