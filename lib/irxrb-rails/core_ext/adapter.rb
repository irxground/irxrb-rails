module ActiveRecord::ConnectionAdapters
  class AbstractAdapter
    def drop_all_views
      if defined?(SQLiteAdapter) && is_a?(SQLiteAdapter)
        unless SQLiteAdapter.include? Irxrb::Rails::SQLiteAdapter
          SQLiteAdapter.class_eval do
            include Irxrb::Rails::SQLiteAdapter
          end
          return self.__send__(__method__)
        end
      end
      if defined?(PostgreSQLAdapter) && is_a?(PostgreSQLAdapter)
        unless PostgreSQLAdapter.include? Irxrb::Rails::PostgreSQLAdapter
          PostgreSQLAdapter.class_eval do
            include Irxrb::Rails::PostgreSQLAdapter
          end
          return self.__send__(__method__)
        end
      end
      raise "#{self.class.name} is not supported."
    end
  end
end
