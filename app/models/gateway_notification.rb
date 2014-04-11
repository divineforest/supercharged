require 'active_merchant'

class GatewayNotification < ActiveRecord::Base
  class EmptyChargeIdError < ArgumentError;end

  belongs_to :charge

  serialize :params

  before_create :set_charge_id

  attr_accessor :raw_post, :logger

  def acknowledge
    res = adapter.acknowledge

    if charge_id.nil? && adapter.item_id
      update_column(:charge_id, adapter.item_id)
    end

    res
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
    raise EmptyChargeIdError unless charge_id

    logger.info "real amount = #{real_amount}"
    charge.approve(real_amount) unless charge.ok?
  end

  def real_amount
    adapter.gross
  end

  private

  def adapter
    @adapter ||= "ActiveMerchant::Billing::Integrations::#{gateway.classify}::Notification".classify.constantize.new(raw_post, Supercharged::Helpers.integrations_options(gateway))
  rescue NameError
    raise "Unknown integration '#{gateway}'"
  end

  def set_charge_id
    self.charge_id ||= adapter.item_id
    true
  end

end
