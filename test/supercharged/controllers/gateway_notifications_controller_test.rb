require 'test_helper'

describe Supercharged::GatewayNotificationsController do
  describe "create" do
    let(:charge) { Charge.create!(user_id: 1, amount: 10) }

    describe "authorized" do
      let(:fake_user) { stub(id: 1) }

      before do
        GatewayNotification.any_instance.stubs(:current_user).returns(fake_user)
      end

      describe "correct conditions" do
        it "works with good notification" do
          adapter = stub(item_id: 1, "complete?" => true, acknowledge: true, charge: charge)

          GatewayNotification.any_instance.stubs(:adapter).returns(adapter)

          post :create, gateway: "webmoney", amount: 100

          charge.reload
          charge.state_name.must_equal :ok

          assert_response :redirect, "/"
        end
      end

      describe "bad conditions" do
        it "completed = false" do
          adapter = stub(item_id: 1, "complete?" => false, acknowledge: true, charge: charge)

          GatewayNotification.any_instance.stubs(:adapter).returns(adapter)

          post :create, gateway: "webmoney", amount: 100

          charge.reload
          charge.state_name.must_equal :error
          charge.error.must_equal "not_completed"

          assert_response :found
        end

        it "acknowledge = false" do
          adapter = stub(item_id: 1, "complete?" => true, acknowledge: false, charge: charge)

          GatewayNotification.any_instance.stubs(:adapter).returns(adapter)

          post :create, gateway: "webmoney", amount: 100

          charge.reload
          charge.state_name.must_equal :error
          charge.error.must_equal "acknowledge_failed"

          assert_response :found
        end
      end
    end

    describe "without any payload params" do
      it "returns bad_request" do
        post :create, gateway: "paypal"

        assert_response :bad_request
      end
    end
  end
end
