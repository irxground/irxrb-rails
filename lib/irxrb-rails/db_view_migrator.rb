module Irxrb::Rails
  class DBViewMigrator

    # ===== ===== ===== CLASS METHODS ===== ===== =====

    class << self
      def run
        @holder = new
        Dir[Rails.root + 'db/migrate/views/**/*.rb'].each{|f| require f }
        @holder.migrate
        @holder = nil
      end

      def define(&block)
        @holder.instance_eval &block
      end
    end

    # ===== ===== ===== INSTANCE METHODS ===== ===== =====

    def initialize
      @views = {}
    end

    def create_view(name, &block)
      depends = []
      case name
      when String
        name = name.to_sym
      when Symbol
        # do nothing
      when Hash
        raise ArgumentError, name.inspect unless name.size == 1
        key = name.keys.first
        depends = Array(name[key]).map{|s| s.to_sym }
        name = key.to_sym
      else
        raise ArgumentError, name.inspect
      end
      raise "Duplicate name: #{name}" if @views.has_key? name
      @views[name] = [depends, block]
    end

    def migrate
      title = 'CREATE VIEW'
      puts "==  #{title} " + '=' * [74 - title.size, 0].max

      @executed = {}
      while @views.size > 0
        name = @views.keys.first
        execute(name)
      end
    end

    private
    def execute(name)
      return                     if @executed[name] == true
      raise 'Infinite Loop'      if @executed[name] == false
      raise "Not Found: #{name}" unless @views.has_key? name

      depends, block = @views.delete name
      @executed[name] = false
      depends.each{|name| execute(name) }
      create(name, &block)
      @executed[name] = true
    end

    def create(name, &block)
      puts "-- #{name}"
      query = yield
      query_str = (query.respond_to?(:to_sql) ? query.to_sql : query).to_s
      try_drop_view name
      send_sql "CREATE VIEW #{name} AS\n" + query_str
    end

    def try_drop_view(name)
      con = ActiveRecord::Base.connection
      case con
      when postgresql?
        con.execute "DROP VIEW #{name} CASCADE" if con.table_exists? name
      when sqlite?
        con.execute "DROP VIEW #{name}" rescue nil
      else
        raise NotImplementedError, "#{con.class.name} is not supported."
      end
    end

    def send_sql(query)
      ActiveRecord::Base.connection.execute(query)
    end

    def sqlite?
      defined?(ActiveRecord::ConnectionAdapters::SQLiteAdapter) and
        ActiveRecord::ConnectionAdapters::SQLiteAdapter
    end

    def postgresql?
      defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) and
        ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
    end
  end
end
