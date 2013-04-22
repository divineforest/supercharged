require 'test_helper'

describe Supercharged::GatewayNotificationsController do
  describe "create action" do
    let(:charge) { Charge.create!({user_id: 1, amount: 10}, without_protection: true) }

    context "authorized" do
      let(:fake_user) { stub(id: 1) }

      before do
        GatewayNotification.any_instance.stubs(:current_user).returns(fake_user)
      end

      context "correct conditions" do
        it "works with good notification" do
          adapter = stub(item_id: 1, "complete?" => true, acknowledge: true, charge: charge)

          GatewayNotification.any_instance.stubs(:adapter).returns(adapter)

          post :create, gateway: "webmoney"

          charge.reload
          charge.state_name.must_equal :ok

          assert_response :redirect, "/"
        end
      end

      context "bad conditions" do

        it "completed = false" do
          adapter = stub(item_id: 1, "complete?" => false, acknowledge: true, charge: charge)

          GatewayNotification.any_instance.stubs(:adapter).returns(adapter)

          post :create, gateway: "webmoney"

          charge.reload
          charge.state_name.must_equal :error
          charge.error.must_equal "not_completed"

          assert_response :bad_request
        end

        it "acknowledge = false" do
          adapter = stub(item_id: 1, "complete?" => true, acknowledge: false, charge: charge)

          GatewayNotification.any_instance.stubs(:adapter).returns(adapter)

          post :create, gateway: "webmoney"

          charge.reload
          charge.state_name.must_equal :error
          charge.error.must_equal "acknowledge_failed"

          assert_response :bad_request
        end

      end
    end
  end
end
