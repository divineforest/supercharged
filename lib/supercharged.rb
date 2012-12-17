require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config/routes'))
require 'supercharged/activemerchant'

require 'state_machine'

module Supercharged
  class Engine < Rails::Engine
  end
end
