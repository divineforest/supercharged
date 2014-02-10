# Supercharged

[![Build Status](https://travis-ci.org/divineforest/supercharged.png?branch=master)](https://travis-ci.org/divineforest/supercharged)
[![Code Climate](https://codeclimate.com/github/divineforest/supercharged.png)](https://codeclimate.com/github/divineforest/supercharged)

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

And then in some assets file:

```
$ ->
  new SuperchargedForm("[role='gateway-charge-form']")
```

Create config/initializers/supercharged.rb

```ruby
ActiveMerchant::Billing::Base.integration_mode = Rails.env.production? ? :production : :test
ActiveMerchant::Billing::Base.mode = Rails.env.production? ? :production : :test
```

Add

```ruby
supercharged
```

to your routes.rb somewhere in draw block.

# Using

Create view in app/views/supercharged/charges/new.html.haml

```haml
= charge_form_for(:paypal, account: 'yourpaypalaccountid', html: {}) do |service|
  - service.description 'Write here description that will be shown in paymennt form'
  = charge_form_amount_field(service)
  = submit_tag 'Pay now'
```

# Customization

## Controller

Create controller in app/controllers/charges_controller.rb and inherit from Supercharged::ChargesController.
Then add what you need or change existing methods with 'super'.

```ruby
class ChargesController < Supercharged::ChargesController
  before_filter :authenticate_user! # this is Devise's authenticate method
end
```

If you create your own controllers then you need to customize routing method:

```
supercharged controllers: {charges: :charges, gateway_notifications: :gateway_notifications}
```

## Model

Create model in app/models/charge.rb and inherit from Supercharged::Charge::Base

```ruby
class Charge < ActiveRecord::Base
  include Supercharged::Charge::Base
  # your custom code here

  def approve(real_amount)
    transaction do
      # update user balance with your own update_balance method or other things you want to do after charged approved
      user.update_balance(real_amount)
      super
    end
  end

  def min_amount
    # specify min value for amount field here
    # default is 1
    42
  end
end
```

## Form

To display validation, supercharged form class has `onValidationError` callback:

```
$ ->
  new SuperchargedForm("[role='gateway-charge-form']", {
    onValidationError: (errors)->
      console.log "supercharged validation errors: ", errors
  })
```

# Contributing

The example app is at https://github.com/divineforest/supercharged-example-app

# License

Supercharged is released under the MIT License
