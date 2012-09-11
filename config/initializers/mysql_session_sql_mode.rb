module ActiveRecord::ConnectionAdapters
  class MysqlAdapter
    def configure_connection
      encoding = @config[:encoding]
      execute("SET NAMES '#{encoding}'") if encoding
      # By default, MySQL 'where id is null' selects the last inserted id.
      # # Turn this off. http://dev.rubyonrails.org/ticket/6778

      execute("SET SQL_AUTO_IS_NULL=0")

      # Explicitly set the SQL mode for the session in case there are problematic global settings
      execute("SET @@SESSION.sql_mode='TRADITIONAL'")
    end
  end
end
