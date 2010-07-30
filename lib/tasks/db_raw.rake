namespace :db do
  namespace :raw do
    desc 'Dump database to FILE or name of RAILS_ENV'
    task :dump do
      verbose(true) unless Rake.application.options.silent

      struct = database_settings
      target = ENV['FILE'] || "#{Rails.env}.sql"
      target_tmp = "#{target}.tmp"
      adapter = struct.adapter

      case adapter
      when 'sqlite3'
        source = struct.database
        sh "sqlite3 #{shellescape source} .dump > #{shellescape target}"
      when 'mysql'
        sh "mysqldump --add-locks --create-options --disable-keys --extended-insert --quick --set-charset #{mysql_credentials_for struct} > #{shellescape target_tmp}"
        mv target_tmp, target
      when 'postgresql'
        sh "pg_dump #{postgresql_credentials_for struct} --clean --no-owner --no-privileges --file #{shellescape target_tmp}"
        mv target_tmp, target
      else
        raise ArgumentError, "Unknown database adapter: #{adapter}"
      end
    end

    desc 'Restore database from FILE'
    task :restore do
      verbose(true) unless Rake.application.options.silent

      source = ENV['FILE']
      raise ArgumentError, 'No FILE argument specified to restore from' unless source

      struct = database_settings
      adapter = struct.adapter

      case adapter
      when 'sqlite3'
        target = struct.database
        mv target, "#{target}.old" if File.exist?(target)
        sh "sqlite3 #{shellescape target} < #{shellescape source}"
      when 'mysql'
        sh "mysql #{mysql_credentials_for struct} < #{shellescape source}"
      when 'postgresql'
        sh "psql #{postgresql_credentials_for struct} < #{shellescape source}"
      else
        raise ArgumentError, "Unknown database adapter: #{adapter}"
      end

      Rake::Task['db:migrate'].invoke
    end
  end

  # Return string escaped for use in shell.
  # Copied from MRI 1.8.7, earlier Ruby versions don't have this.
  def shellescape(str)
    # An empty argument will be skipped, so return empty quotes.
    return "''" if str.empty?

    str = str.dup

    # Process as a single byte sequence because not all shell
    # implementations are multibyte aware.
    str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")

    # A LF cannot be escaped with a backslash because a backslash + LF
    # combo is regarded as line continuation and simply ignored.
    str.gsub!(/\n/, "'\n'")

    return str
  end

  # Return OpenStruct representing current environment's database.yml file.
  def database_settings
    require 'erb'
    require 'yaml'
    require 'ostruct'

    return @database_settings_cache ||= OpenStruct.new(
      YAML.load(
        ERB.new(
          File.read(
            File.join(Rails.root, 'config', 'database.yml'))).result)[Rails.env])
  end

  # Return string with MySQL credentials for use on a command-line.
  def mysql_credentials_for(struct)
    result = []
    result << "--user=#{shellescape struct.username}" if struct.username
    result << "--password=#{shellescape struct.password}" if struct.password
    result << "--host=#{shellescape struct.host}" if struct.host
    result << "#{shellescape struct.database}"
    return result.join(' ')
  end

  # Return string with PostgreSQL credentials for use on a command-line.
  def postgresql_credentials_for(struct)
    result = []
    result << "-U #{shellescape struct.username}" if struct.username
    result << "-h #{shellescape struct.host}" if struct.host
    result << "-p #{shellescape struct.port}" if struct.port
    result << "#{shellescape struct.database}"
    return result.join(' ')
  end
end
