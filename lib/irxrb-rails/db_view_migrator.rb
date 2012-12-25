module Irxrb::Rails
  class DBViewMigrator

    # ===== ===== ===== CLASS METHODS ===== ===== =====

    class << self
      def drop_all
        announce 'DROP VIEWS'
        ActiveRecord::Base.connection.drop_all_views
      end

      def migrate(paths = nil)
        if block_given?
          drop_all
          yield
          migrate(paths)
          return
        end

        announce 'CREATE VIEWS'

        paths = paths.presence || ActiveRecord::Migrator.migrations_paths
        paths = Array.wrap(paths)
        @holder = new
        Dir[*paths.map { |path| path + '/views/**/*.rb' }].each { |f| require f }
        @holder.migrate
        @holder = nil
      end

      def define(&block)
        @holder.instance_eval &block
      end

      private

      def announce(text)
        if ActiveRecord::Migration.verbose
          ActiveRecord::Migration.announce text
        end
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
      execute_core(name, &block)
      @executed[name] = true
    end

    def execute_core(name, &block)
      say name
      query = yield
      query_str = (query.respond_to?(:to_sql) ? query.to_sql : query).to_s
      ActiveRecord::Base.connection.execute "CREATE VIEW #{name} AS\n" + query_str
    end

    def say(text)
      if ActiveRecord::Migration.verbose
        ActiveRecord::Migration.say text
      end
    end
  end
end
