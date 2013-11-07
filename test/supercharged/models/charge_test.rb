require 'test_helper'

describe Charge do
  describe "validations" do
    subject { Charge.new }
    it "amount is required" do
      subject.valid?

      subject.errors[:amount][0].must_equal "can't be blank"
    end

    it "min amount is required" do
      subject.amount = 0
      subject.valid?

      subject.errors[:amount][0].must_equal "must be greater than or equal to 1"

      subject.amount = 100
      subject.valid?.must_equal true
    end
  end

  describe "states" do
    subject { Charge.create!(user_id: 1, amount: 10) }

    describe "initial state" do
      it "initial state is new" do
        Charge.new.state_name.must_equal :new
      end
    end

    describe "#approve" do
      it "changes state and real_amount" do
        subject.approve(5)

        subject.real_amount.must_equal 5
        subject.state_name.must_equal :ok
      end
    end
  end
end