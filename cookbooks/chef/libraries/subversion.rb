class Chef
  class Provider
    class Subversion
      def sync_command
        if current_repository_matches_target_repository?
          c = scm :update, @new_resource.svn_arguments, verbose, authentication, "-r#{revision_int}", @new_resource.destination
          Chef::Log.debug "#{@new_resource} updated working copy #{@new_resource.destination} to revision #{@new_resource.revision}"
        else
          c = scm :switch, @new_resource.svn_arguments, verbose, authentication, "-r#{revision_int}", @new_resource.repository, @new_resource.destination
          Chef::Log.debug "#{@new_resource} updated working copy #{@new_resource.destination} to #{@new_resource.repository} revision #{@new_resource.revision}"
        end
        c
      end

      def current_repository
        @current_repository ||= repo_attrs['URL']
      end

      def current_repository_matches_target_repository?
        (!current_repository.nil?) && (@new_resource.repository == current_repository)
      end

      def repo_attrs
        return {} unless ::File.exist?(::File.join(@new_resource.destination, ".svn"))

        @repo_attrs ||= svn_info.lines.inject({}) do |attrs, line|
          if line =~ SVN_INFO_PATTERN
            property, value = $1, $2
            attrs[property] = value
          else
            raise "Could not parse `svn info` data: #{line}"
          end
          attrs
        end
      end

      def svn_info
        command = scm(:info)
        status, svn_info, error_message = output_of_command(command, run_options(:cwd => cwd))

        unless [0, 1].include?(status.exitstatus)
          handle_command_failures(status, "STDOUT: #{svn_info}\nSTDERR: #{error_message}")
        end

        svn_info
      end
    end
  end
end
