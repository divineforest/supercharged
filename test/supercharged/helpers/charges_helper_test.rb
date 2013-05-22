require 'test_helper'

class Supercharged::ChargesHelperTest < ActionView::TestCase
  def test_min_value
    field = charge_form_amount_field(sample_service, { min: 500 })
    field.must_include 'min="500"'
  end

  def sample_service
    stub(mappings: { amount: "amount" })
  end
end
