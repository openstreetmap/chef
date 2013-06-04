require 'chef/mixin/command'

class Chef
  class PostgreSQL
    include Chef::Mixin::Command

    TABLE_PRIVILEGES = [
      :select, :insert, :update, :delete, :truncate, :references, :trigger
    ]

    def initialize(cluster)
      @cluster = cluster
    end

    def execute(options)
      # Create argument array
      args = []

      # Build the arguments
      args.push("--command=\"#{options[:command].gsub('"', '\\"')}\"") if options[:command]
      args.push("--file=#{options[:file]}") if options[:file]

      # Get the database to use
      database = options[:database] || "template1"

      # Build the command to run
      command = "/usr/bin/psql --cluster #{@cluster} #{args.join(' ')} #{database}"

      # Get the user and group to run as
      user = options[:user] || "postgres"
      group = options[:group] || "postgres"

      # Run the command
      run_command(:command => command, :user => user, :group => group)
    end

    def query(sql, options = {})
      # Get the database to use
      database = options[:database] || "template1"

      # Construct the command string
      command = "/usr/bin/psql --cluster #{@cluster} --no-align --command='#{sql}' #{database}"

      # Run the query
      status, stdout, stderr = output_of_command(command, :user => "postgres", :group => "postgres")
      handle_command_failures(status, "STDOUT: #{stdout}\nSTDERR: #{stderr}", :output_on_failure => true)

      # Split the output into lines
      lines = stdout.split("\n")

      # Remove the "(N rows)" line from the end
      lines.pop

      # Get the field names
      fields = lines.shift.split("|")

      # Extract the record data
      lines.collect do |line|
        record = {}
        fields.zip(line.split("|")) { |name,value| record[name.to_sym] = value }
        record
      end
    end

    def users
      @users ||= query("SELECT * FROM pg_user").inject({}) do |users,user|
        users[user[:usename]] = {
          :superuser => user[:usesuper] == "t",
          :createdb => user[:usercreatedb] == "t",
          :createrole => user[:usecatupd] == "t",
          :replication => user[:userepl] == "t"
        }
        users
      end
    end

    def databases
      @databases ||= query("SELECT d.datname, u.usename, d.encoding, d.datcollate, d.datctype FROM pg_database AS d INNER JOIN pg_user AS u ON d.datdba = u.usesysid").inject({}) do |databases,database|
        databases[database[:datname]] = {
          :owner => database[:usename],
          :encoding => database[:encoding],
          :collate => database[:datcollate],
          :ctype => database[:datctype]
        }
        databases
      end
    end

    def extensions(database)
      @extensions ||= {}
      @extensions[database] ||= query("SELECT extname, extversion FROM pg_extension", :database => database).inject({}) do |extensions,extension|
        extensions[extension[:extname]] = {
          :version => extension[:extversion]
        }
        databases
      end
    end

    def tables(database)
      @tables ||= {}
      @tables[database] ||= query("SELECT n.nspname, c.relname, u.usename, c.relacl FROM pg_class AS c INNER JOIN pg_user AS u ON c.relowner = u.usesysid INNER JOIN pg_namespace AS n ON c.relnamespace = n.oid", :database => database).inject({}) do |tables,table|
        name = "#{table[:nspname]}.#{table[:relname]}"

        tables[name] = {
          :owner => table[:usename],
          :permissions => parse_acl(table[:relacl] || "{}")
        }

        tables
      end
    end

  private

    def parse_acl(acl)
      acl.sub(/^\{(.*)\}$/, "\\1").split(",").inject({}) do |permissions, entry|
        entry = entry.sub(/^"(.*)"$/) { $1.gsub(/\\"/, '"') }.sub(/\/.*$/, "")
        user, privileges = entry.split("=")

        user = user.sub(/^"(.*)"$/, "\\1")
        user = "public" if user == ""

        permissions[user] = {
          "a" => :insert, "r" => :select, "w" => :update, "d" => :delete,
          "D" => :truncate, "x" => :references, "t" => :trigger
        }.values_at(*(privileges.chars)).compact

        permissions
      end
    end
  end
end
