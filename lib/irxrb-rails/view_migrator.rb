module Irxrb::Rails
  class ViewMigrator

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
      puts "==== CREATE VIEW ===="
      @executed = {}
      while @views.size > 0
        name = @views.keys.first
        execute(name)
      end
    end

    private
    def execute(name)
      return                     if @executed[name] == true
      raise 'Infinit Loop'       if @executed[name] == false
      raise "Not Found: #{name}" unless @views.has_key? name

      depends, block = @views.delete name
      @executed[name] = false
      depends.each{|name| execute(name) }
      run_sql(name, &block)
      @executed[name] = true
    end

    def run_sql(name, &block)
      puts "--> #{name}"
      query = block.call
      query_str = (query.respond_to?(:to_sql) ? query.to_sql : query).to_s
      begin
        exec "SELECT * FROM #{name} LIMIT 1"
        exec "DROP VIEW #{name}"
      rescue
        # do nothing
      end

      exec "CREATE VIEW #{name} AS " + query_str
    end

    def exec(query)
      ActiveRecord::Base.connection.execute(query)
    end
  end
end
