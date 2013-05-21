require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module Supercharged
  module Generators
    class MigrationsGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("../templates", __FILE__)

      desc "Generates migration for Supercharged"

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def copy_migration
        migration_template 'install_migration.rb', 'db/migrate/install_supercharged.rb'
      end

      def mount_engine
        route "supercharged"
      end
    end
  end
end
