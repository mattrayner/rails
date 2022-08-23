module ActiveRecord
  module TemporaryConnection # :nodoc:
    def self.for_config(db_config)
      pool = establish_connection(db_config)
      yield pool.connection
    ensure
      ActiveRecord::Base.connection_handler.instance_variable_get(:@connection_name_to_pool_manager).delete(self.name)
      nil
    end

    def self.establish_connection(db_config)
      ActiveRecord::Base.connection_handler.establish_connection(db_config, owner_name: self, role: :writing, shard: :default)
    end

    def self.current_connection_db_config
      current_pool.db_config
    end

    def self.current_connection
      if pool = find_connection_pool
        pool.connection
      else
        ActiveRecord::Base.connection
      end
    end

    def self.current_pool
      if pool = find_connection_pool
        pool
      else
        ActiveRecord::Base.connection_pool
      end
    end

    def self.find_connection_pool
      ActiveRecord::Base.connection_handler.retrieve_connection_pool(name, role: :writing, shard: :default)
    end

    def self.find_connection
      if pool = find_connection_pool
        pool.connection
      end
    end

    def self.primary_class?
      false
    end

    def self.current_preventing_writes
      false
    end
  end
end