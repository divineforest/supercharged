# Supercharged

Complete MVC solution to accept charges from users on your Ruby on Rails site

## Installation

Add to Gemfile:

```ruby
gem 'supercharged'

```

run

    rails g supercharged:migrations
    rails db:migrate
    rails g supercharged:views

In your application.js manifest:

```
//= require supercharged
```

# Using

Create view in app/views/supercharged/charges/new.html.haml

```haml
= charge_form_for(:paypal, account: "yourpaypalaccountid", html: {}) do |service|
  - service.description t('.payment_service_invoice_description')
  = charge_form_amount_field(service)
  = submit_tag t('.refill')

```

# Customization

## Controller

Create controller in app/controllers/charges_controller.rb and inherit from Payments::ChargesController.
Then add what you need or change existing methods with 'super'.

```ruby
class ChargesController < Payments::ChargesController
  before_filter :authenticate_user! # this is Devise's authenticate method
end
```

## Model

Create model in app/models/charge.rb and inherit from Supercharged::Charge::Base

```ruby
class Charge < Supercharged::Charge::Base
  # your custom code here

  def existing_gem_method
    # your custom code here
    super
    # your custom code here
  end
end
```

# License

Supercharged is released under the MIT License
