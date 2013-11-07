module ActionDispatch::Routing
  class Mapper

    def supercharged(options = {})
      controllers = {
        charges: "supercharged/charges",
        gateway_notifications: "supercharged/gateway_notifications"
      }
      controllers.merge!(options[:controllers]) if options[:controllers]

      resources :charges, only: [:new, :create], controller: controllers[:charges] do
        collection do
          post :setup_purchase
          get :complete
        end
      end

      post "gateways/:gateway/result" => "#{controllers[:gateway_notifications]}#create", as: :gateways_result
    end

  end
end
