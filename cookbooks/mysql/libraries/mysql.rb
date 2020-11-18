require "chef/mixin/shell_out"
require "rexml/document"

module OpenStreetMap
  module MySQL
    include Chef::Mixin::ShellOut

    USER_PRIVILEGES = [
      :select, :insert, :update, :delete, :create, :drop, :reload,
      :shutdown, :process, :file, :grant, :references, :index, :alter,
      :show_db, :super, :create_tmp_table, :lock_tables, :execute,
      :repl_slave, :repl_client, :create_view, :show_view, :create_routine,
      :alter_routine, :create_user, :event, :trigger, :create_tablespace
    ].freeze

    DATABASE_PRIVILEGES = [
      :select, :insert, :update, :delete, :create, :drop, :grant,
      :references, :index, :alter, :create_tmp_table, :lock_tables,
      :create_view, :show_view, :create_routine, :alter_routine,
      :execute, :event, :trigger
    ].freeze

    def mysql_execute(options)
      # Create argument array
      args = []

      # Work out how to authenticate
      if options[:user]
        args.push("--username")
        args.push(options[:user])

        if options[:password]
          args.push("--password")
          args.push(options[:password])
        end
      else
        args.push("--defaults-file=/etc/mysql/debian.cnf")
      end

      # Set output format
      args.push("--xml") if options[:xml]

      # Add any SQL command to execute
      if options[:command]
        args.push("--execute")
        args.push(options[:command])
      end

      # Add the database name
      args.push(options[:database] || "mysql")

      # Run the command
      shell_out!("/usr/bin/mysql", *args, :user => "root", :group => "root")
    end

    def query(sql, options = {})
      # Run the query
      result = mysql_execute(options.merge(:command => sql, :xml => true))

      # Parse the output
      document = REXML::Document.new(result.stdout)

      # Create
      records = []

      # Loop over the rows in the result set
      document.root.each_element("/resultset/row") do |row|
        # Create a record
        record = {}

        # Loop over the fields, adding them to the record
        row.each_element("field") do |field|
          name = field.attributes["name"].downcase
          value = field.text

          record[name.to_sym] = value
        end

        # Add the record to the record list
        records << record
      end

      # Return the record list
      records
    end

    def mysql_users
      privilege_columns = USER_PRIVILEGES.collect { |privilege| "#{privilege}_priv" }.join(", ")

      @mysql_users ||= query("SELECT user, host, #{privilege_columns} FROM user").each_with_object({}) do |user, users|
        name = "'#{user[:user]}'@'#{user[:host]}'"

        users[name] = USER_PRIVILEGES.each_with_object({}) do |privilege, privileges|
          privileges[privilege] = user["#{privilege}_priv".to_sym] == "Y"
        end
      end
    end

    def mysql_databases
      @mysql_databases ||= query("SHOW databases").each_with_object({}) do |database, databases|
        databases[database[:database]] = {
          :permissions => {}
        }
      end

      query("SELECT * FROM db").each do |record|
        database = @mysql_databases[record[:db]]

        next unless database

        user = "'#{record[:user]}'@'#{record[:host]}'"

        database[:permissions][user] = DATABASE_PRIVILEGES.each_with_object([]) do |privilege, privileges|
          privileges << privilege if record["#{privilege}_priv".to_sym] == "Y"
        end
      end

      @mysql_databases
    end

    def mysql_canonicalise_user(user)
      local, host = user.split("@")

      host ||= "%"

      local = "'#{local}'" unless local =~ /^'.*'$/
      host = "'#{host}'" unless host =~ /^'.*'$/

      "#{local}@#{host}"
    end

    def mysql_privilege_name(privilege)
      case privilege
      when :grant
        "GRANT OPTION"
      when :show_db
        "SHOW DATABASES"
      when :repl_slave
        "REPLICATION SLAVE"
      when :repl_client
        "REPLICATION CLIENT"
      when :create_tmp_table
        "CREATE TEMPORARY TABLES"
      else
        privilege.to_s.upcase.tr("_", " ")
      end
    end
  end
end
