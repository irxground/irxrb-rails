
module ActiveRecord::ConnectionAdapters

  class AbstractAdapter
    def drop_all_views
      raise "#{self.class.name} is not supported."
    end
  end

  if defined? SQLiteAdapter
    class SQLiteAdapter
      def drop_all_views
        table = Arel::Table.new('sqlite_master')
        ActiveRecord::Base.transaction do
          result = execute(
            table
              .where(table[:type].eq 'view')
              .project(table[:name])
              .to_sql)
          result.each do |row|
            name = row['name']
            execute "DROP VIEW #{name}"
          end
        end
      end
    end
  end

  if defined? PostgreSQLAdapter
    class PostgreSQLAdapter
      def drop_all_views
        table = Arel::Table.new('pg_views')
        ActiveRecord::Base.transaction do
          result = execute(
            table
              .where(table[:schemaname].eq 'public')
              .project(table[:viewname])
              .to_sql)
          result.each do |row|
            name = row['viewname']
            execute "DROP VIEW IF EXISTS #{name} CASCADE"
          end
        end
      end
    end
  end
end
