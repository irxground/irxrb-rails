module Irxrb
  module Rails
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load 'irxrb-rails/tasks/irxrb-rails_tasks.rake'
      end

      initializer 'irxrb-rails.core_ext', after: 'active_record.initialize_database' do
        load 'irxrb-rails/core_ext/adapter.rb'
      end
    end
  end
end

