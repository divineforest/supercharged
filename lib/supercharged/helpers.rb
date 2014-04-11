module Supercharged
  module Helpers
    @gateways = {}
    @integrations_options = {}

    def self.gateway(name)
      @gateways[name.to_sym] || raise("Gateway not registered")
    end

    def self.init_gateway(name, options)
      klass = gateway_class_by_name(name)
      gateway = klass.new(options)
      add_gateway(name, gateway)
    end

    def self.init_integration(name, options)
      @integrations_options[name.to_sym] = options
    end

    def self.integrations_options(name)
      @integrations_options[name.to_sym]
    end

    private

    def self.gateway_class_by_name(name)
      "ActiveMerchant::Billing::#{name.to_s.camelcase}Gateway".classify.constantize
    rescue NameError
      raise "Unknown gateway '#{name}'"
    end

    def self.add_gateway(name, gateway)
      @gateways[name.to_sym] = gateway
    end
  end
end
