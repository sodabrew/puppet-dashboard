module ActiveRecord::ConnectionAdapters
  class MysqlAdapter
    alias :configure_connection_old :configure_connection
    def configure_connection
      # Explicitly set the SQL mode for the session in case there are problematic global settings
      execute("SET @@SESSION.sql_mode='TRADITIONAL'")

      configure_connection_old()
    end
  end
end
