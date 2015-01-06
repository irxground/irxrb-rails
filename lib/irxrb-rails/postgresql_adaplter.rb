module Irxrb::Rails::PostgreSQLAdapter
  def drop_all_views
    table = Arel::Table.new('pg_views')
    ActiveRecord::Base.transaction do
      result = execute(
        table
          .where(table[:schemaname].eq 'public')
          .project(table[:viewname])
          .to_sql)
      names = result.map{|row| row['viewname'] }.join(', ')
      execute "DROP VIEW IF EXISTS #{names} CASCADE"
    end
  end
end
