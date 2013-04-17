ENV["RAILS_ENV"] = "test"

require "minitest/autorun"
require "minitest/spec"
require "minitest/pride"
require "minitest-spec-context"

require 'rails'
require 'active_record'
require 'action_view'
require 'state_machine'
require 'state_machine-audit_trail'

require "supercharged"
require "fake_app"