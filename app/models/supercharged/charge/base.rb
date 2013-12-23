module Supercharged
  module Charge
    module Base
      extend ActiveSupport::Concern

      included do
        self.table_name = "charges"

        belongs_to :user
        has_many :gateway_input_notifications
        has_many :gateway_responses

        validates :amount, presence: true, numericality: {
          greater_than_or_equal_to: ->(model) {
            model.class.min_amount
          }
        }

        scope :latest, ->{ order("created_at DESC") }
        scope :by_gateway, ->(gateway_name) { where(gateway_name: gateway_name.to_s) }

        state_machine :state, initial: :new do
          # store_audit_trail

          state :new
          state :rejected
          state :ok
          state :error

          event :set_ok do
            transition [:new, :error, :pending] => :ok
          end

          event :set_failed do
            transition [:new, :pending] => :error
          end

          event :reject do
            transition [:new, :error, :pending] => :rejected
          end

          event :set_pending do
            transition [:new, :error] => :pending
          end
        end
      end

      module ClassMethods
        def with_token(token)
          where(gateway_token: token).first
        end

        def min_amount
          1
        end
      end

      # require implicit amount from gateway, not from user
      def approve(real_amount)
        self.real_amount = real_amount
        set_ok!
      end

      def setup_purchase(options)
        response = gateway.setup_purchase(amount_in_cents,
          ip: options[:id],
          return_url: options[:return_url],
          cancel_return_url: options[:cancel_return_url]
        )

        if response.success?
          update_attributes!(
            gateway_token: response.token,
            ip_address: options[:id]
          )
        end

        response.token
      end

      def complete(options = {})
        get_purchase_details

        response = process_purchase

        approve(amount) if response.success?

        response.success?
      end

      def gateway
        Supercharged::Helpers.gateway(gateway_name)
      end

      def min_amount
        1
      end

      def fail
        self.state_event = "set_failed"
        save(validate: false)
      end

      private

      def amount_in_cents
        amount * 100
      end

      def get_purchase_details
        details = gateway.details_for(gateway_token)
        self.gateway_payer_id = details.payer_id
      end

      def process_purchase
        response = gateway.purchase(amount_in_cents,
          ip: ip_address,
          token: gateway_token,
          payer_id: gateway_payer_id
        )

        save_gateway_response(response)

        response
      end

      def save_gateway_response(response)
        GatewayResponse.create!(charge: self, action: "purchase", amount: amount, response: response)
      end
    end
  end
end
