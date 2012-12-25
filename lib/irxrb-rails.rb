require 'irxrb-rails/version'

module Irxrb
  module Rails
    autoload :DBViewMigrator, 'irxrb-rails/db_view_migrator'
  end
end

require 'irxrb-rails/railtie' if defined?(Rails)
