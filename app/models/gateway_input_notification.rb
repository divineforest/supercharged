require 'active_merchant'

class GatewayInputNotification < ActiveRecord::Base
  belongs_to :charge

  serialize :params

  before_create :set_charge_id

  attr_accessor :raw_post

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

  private

  def adapter
    @adapter ||= "ActiveMerchant::Billing::Integrations::#{gateway.classify}::Notification".classify.constantize.new(raw_post)
  rescue NameError
    raise "Unknown integration '#{gateway}'"
  end

  def set_charge_id
    self.charge_id = adapter.item_id || raise("Undefined charge_id")
  end

end
