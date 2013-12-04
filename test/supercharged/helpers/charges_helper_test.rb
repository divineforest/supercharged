require 'test_helper'

class Supercharged::ChargesHelperTest < ActionView::TestCase
  def test_min_value
    self.stubs(:current_user).returns(User.new)
    Charge.any_instance.stubs(:min_amount).returns(500)
    field = charge_form_amount_field(sample_service)
    field.must_include 'min="500"'
  end

  def sample_service
    stub(mappings: { amount: "amount" })
  end
end
