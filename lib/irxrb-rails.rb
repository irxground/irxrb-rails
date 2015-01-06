require 'irxrb-rails/version'

module Irxrb
  module Rails
    autoload :DBViewMigrator,    'irxrb-rails/db_view_migrator'
    autoload :SQLiteAdapter,     'irxrb-rails/sqlite_adaplter.rb'
    autoload :PostgreSQLAdapter, 'irxrb-rails/postgresql_adaplter.rb'
  end
end

require 'irxrb-rails/railtie' if defined?(Rails)
