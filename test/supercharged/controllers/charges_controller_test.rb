require 'test_helper'

describe Supercharged::ChargesController do
  describe "create action" do
    context "authorized" do
      let(:fake_user) { User.create! }

      before do
        Supercharged::ChargesController.any_instance.stubs(:current_user).returns(fake_user)
      end

      context "correct conditions" do
        it "response contains id in json" do
          post :create, charge: { amount: 100 }

          assert_response :success

          expected = {"charge"=>{"id"=>1}}
          JSON.parse(@response.body).must_equal(expected)
        end
      end

      context "bad conditions" do
        it "response contains errors in json" do
          post :create, charge: { amount: 0 }

          assert_response 422

          expected = {"errors"=>{"amount"=>["must be greater than or equal to 1"]}}
          JSON.parse(@response.body).must_equal(expected)
        end
      end
    end
  end
end
