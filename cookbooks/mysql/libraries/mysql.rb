require "chef/mixin/command"
require "rexml/document"

class Chef
  class MySQL
    include Chef::Mixin::Command

    USER_PRIVILEGES = [
      :select, :insert, :update, :delete, :create, :drop, :reload,
      :shutdown, :process, :file, :grant, :references, :index, :alter,
      :show_db, :super, :create_tmp_table, :lock_tables, :execute,
      :repl_slave, :repl_client, :create_view, :show_view, :create_routine,
      :alter_routine, :create_user, :event, :trigger, :create_tablespace
    ]

    DATABASE_PRIVILEGES = [
      :select, :insert, :update, :delete, :create, :drop, :grant,
      :references, :index, :alter, :create_tmp_table, :lock_tables,
      :create_view, :show_view, :create_routine, :alter_routine,
      :execute, :event, :trigger
    ]

    def execute(options)
      # Create argument array
      args = []

      # Work out how to authenticate
      if options[:user]
        args.push("--username=#{options[:user]}")
        args.push("--password=#{options[:password]}") if options[:password]
      else
        args.push("--defaults-file=/etc/mysql/debian.cnf")
      end

      # Build the other arguments
      args.push("--execute=\"#{options[:command]}\"") if options[:command]

      # Get the database to use
      database = options[:database] || "mysql"

      # Build the command to run
      command = "/usr/bin/mysql #{args.join(' ')} #{database}"

      # Escape backticks in the command
      command.gsub!(/`/, "\\\\`")

      # Run the command
      run_command(:command => command, :user => "root", :group => "root")
    end

    def query(sql, options = {})
      # Get the database to use
      database = options[:database] || "mysql"

      # Construct the command string
      command = "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf --xml --execute='#{sql}' #{database}"

      # Run the query
      status, stdout, stderr = output_of_command(command, :user => "root", :group => "root")
      handle_command_failures(status, "STDOUT: #{stdout}\nSTDERR: #{stderr}", :output_on_failure => true)

      # Parse the output
      document = REXML::Document.new(stdout)

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

    def users
      @users ||= query("SELECT * FROM user").inject({}) do |users, user|
        name = "'#{user[:user]}'@'#{user[:host]}'"

        users[name] = USER_PRIVILEGES.inject({}) do |privileges, privilege|
          privileges[privilege] = user["#{privilege}_priv".to_sym] == "Y"
          privileges
        end

        users
      end
    end

    def databases
      @databases ||= query("SHOW databases").inject({}) do |databases, database|
        databases[database[:database]] = {
          :permissions => {}
        }
        databases
      end

      query("SELECT * FROM db").each do |record|
        if database = @databases[record[:db]]
          user = "'#{record[:user]}'@'#{record[:host]}'"

          database[:permissions][user] = DATABASE_PRIVILEGES.inject([]) do |privileges, privilege|
            privileges << privilege if record["#{privilege}_priv".to_sym] == "Y"
            privileges
          end
        end
      end

      @databases
    end

    def canonicalise_user(user)
      local, host = user.split("@")

      host = "%" unless host

      local = "'#{local}'" unless local =~ /^'.*'$/
      host = "'#{host}'" unless host =~ /^'.*'$/

      "#{local}@#{host}"
    end

    def privilege_name(privilege)
      case privilege
      when :grant
        "GRANT OPTION"
      when :create_tmp_table
        "CREATE TEMPORARY TABLES"
      else
        privilege.to_s.upcase.tr("_", " ")
      end
    end
  end
end
