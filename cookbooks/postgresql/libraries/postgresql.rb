require "chef/mixin/shell_out"

module OpenStreetMap
  class PostgreSQL
    include Chef::Mixin::ShellOut

    TABLE_PRIVILEGES = [
      :select, :insert, :update, :delete, :truncate, :references, :trigger
    ].freeze

    SEQUENCE_PRIVILEGES = [
      :usage, :select, :update
    ].freeze

    def initialize(cluster)
      @cluster = cluster
    end

    def version
      @cluster.split("/").first.to_f
    end

    def execute(options)
      # Create argument array
      args = []

      # Add the cluster
      args.push("--cluster")
      args.push(@cluster)

      # Set output format
      args.push("--no-align") unless options.fetch(:align, true)

      # Add any SQL command to execute
      if options[:command]
        args.push("--command")
        args.push(options[:command])
      end

      # Add any file to execute SQL commands from
      if options[:file]
        args.push("--file")
        args.push(options[:file])
      end

      # Add the database name
      args.push(options[:database] || "template1")

      # Get the user and group to run as
      user = options[:user] || "postgres"
      group = options[:group] || "postgres"

      # Run the command
      shell_out!("/usr/bin/psql", *args, :user => user, :group => group)
    end

    def query(sql, options = {})
      # Run the query
      result = execute(options.merge(:command => sql, :align => false))

      # Split the output into lines
      lines = result.stdout.split("\n")

      # Remove the "(N rows)" line from the end
      lines.pop

      # Get the field names
      fields = lines.shift.split("|")

      # Extract the record data
      lines.collect do |line|
        record = {}
        fields.zip(line.split("|")) { |name, value| record[name.to_sym] = value }
        record
      end
    end

    def users
      @users ||= query("SELECT *, ARRAY(SELECT groname FROM pg_group WHERE usesysid = ANY(grolist)) AS roles FROM pg_user").each_with_object({}) do |user, users|
        users[user[:usename]] = {
          :superuser => user[:usesuper] == "t",
          :createdb => user[:usercreatedb] == "t",
          :createrole => user[:usecatupd] == "t",
          :replication => user[:userepl] == "t",
          :roles => parse_array(user[:roles] || "{}")
        }
      end
    end

    def databases
      @databases ||= query("SELECT d.datname, u.usename, d.encoding, d.datcollate, d.datctype FROM pg_database AS d INNER JOIN pg_user AS u ON d.datdba = u.usesysid").each_with_object({}) do |database, databases|
        databases[database[:datname]] = {
          :owner => database[:usename],
          :encoding => database[:encoding],
          :collate => database[:datcollate],
          :ctype => database[:datctype]
        }
      end
    end

    def extensions(database)
      @extensions ||= {}
      @extensions[database] ||= query("SELECT extname, extversion FROM pg_extension", :database => database).each_with_object({}) do |extension, extensions|
        extensions[extension[:extname]] = {
          :version => extension[:extversion]
        }
      end
    end

    def tablespaces
      @tablespaces ||= query("SELECT spcname, usename FROM pg_tablespace AS t INNER JOIN pg_user AS u ON t.spcowner = u.usesysid").each_with_object({}) do |tablespace, tablespaces|
        tablespaces[tablespace[:spcname]] = {
          :owner => tablespace[:usename]
        }
      end
    end

    def tables(database)
      @tables ||= {}
      @tables[database] ||= query("SELECT n.nspname, c.relname, u.usename, c.relacl FROM pg_class AS c INNER JOIN pg_user AS u ON c.relowner = u.usesysid INNER JOIN pg_namespace AS n ON c.relnamespace = n.oid WHERE n.nspname NOT IN ('pg_catalog', 'information_schema') AND c.relkind = 'r'", :database => database).each_with_object({}) do |table, tables|
        name = "#{table[:nspname]}.#{table[:relname]}"

        tables[name] = {
          :owner => table[:usename],
          :permissions => parse_acl(table[:relacl] || "{}")
        }
      end
    end

    def sequences(database)
      @sequences ||= {}
      @sequences[database] ||= query("SELECT n.nspname, c.relname, u.usename, c.relacl FROM pg_class AS c INNER JOIN pg_user AS u ON c.relowner = u.usesysid INNER JOIN pg_namespace AS n ON c.relnamespace = n.oid WHERE n.nspname NOT IN ('pg_catalog', 'information_schema') AND c.relkind = 'S'", :database => database).each_with_object({}) do |sequence, sequences|
        name = "#{sequence[:nspname]}.#{sequence[:relname]}"

        sequences[name] = {
          :owner => sequence[:usename],
          :permissions => parse_acl(sequence[:relacl] || "{}")
        }
      end
    end

    private

    def parse_array(array)
      array.sub(/^\{(.*)\}$/, "\\1").split(",")
    end

    def parse_acl(acl)
      parse_array(acl).each_with_object({}) do |entry, permissions|
        entry = entry.sub(/^"(.*)"$/) { Regexp.last_match[1].gsub(/\\"/, '"') }.sub(%r{/.*$}, "")
        user, privileges = entry.split("=")

        user = user.sub(/^"(.*)"$/, "\\1")
        user = "public" if user == ""

        permissions[user] = {
          "r" => :select, "a" => :insert, "w" => :update, "d" => :delete,
          "D" => :truncate, "x" => :references, "t" => :trigger,
          "C" => :create, "c" => :connect, "T" => :temporary,
          "X" => :execute, "U" => :usage, "s" => :set, "A" => :alter_system
        }.values_at(*privileges.chars).compact
      end
    end
  end
end
