require 'test_helper'

describe GatewayNotification do
  describe "create" do
    it "raise EmptyChargeId if charge_id = nil" do
      ->{
        notification = GatewayNotification.create!(gateway: "webmoney")
        notification.approve
      }.must_raise GatewayNotification::EmptyChargeIdError
    end

    it "charge id is inherited from adapter" do
      gateway_notification = GatewayNotification.new

      adapter = stub(item_id: 42)
      gateway_notification.stubs(:adapter).returns(adapter)

      gateway_notification.save!
      gateway_notification.charge_id.must_equal 42
    end
  end
end