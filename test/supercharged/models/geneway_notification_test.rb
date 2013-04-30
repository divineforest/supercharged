require 'test_helper'

describe GatewayNotification do
  describe "create" do
    it "raise EmptyChargeId if charge_id = nil" do
      ->{
        GatewayNotification.create!(gateway: "webmoney")
      }.must_raise GatewayNotification::EmptyChargeIdError
    end
  end
end