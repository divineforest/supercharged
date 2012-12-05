module Supercharged
  module Charge
    class Base < Payment

      has_many :gateway_input_notifications

      state_machine :state, initial: :new do
        store_audit_trail

        state :new
        state :rejected
        state :ok
        state :error

        event :set_ok do
          transition [:new, :error] => :ok
        end

        event :failed do
          transition [:new] => :error
        end

        event :reject do
          transition [:new, :error] => :rejected
        end
      end

      # require implicit amount from gateway, not from user
      def approve(real_amount)
        self.real_amount = real_amount
        set_ok!
      end

    end
  end
end
