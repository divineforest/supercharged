class PaymentStateTransition < ActiveRecord::Base
  belongs_to :payment
end
