module Irxrb::Rails::SQLiteAdapter
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
