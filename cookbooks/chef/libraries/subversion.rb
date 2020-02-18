require "chef/mixin/shell_out"

class Chef
  class Provider
    class Subversion
      extend Chef::Mixin::ShellOut

      def sync_command
        if current_repository_matches_target_repository?
          c = scm :update, new_resource.svn_arguments, verbose, authentication, proxy, "-r#{revision_int}", new_resource.destination
          Chef::Log.debug "#{new_resource} updated working copy #{new_resource.destination} to revision #{new_resource.revision}"
        else
          c = scm :switch, new_resource.svn_arguments, verbose, authentication, proxy, "-r#{revision_int}", new_resource.repository, new_resource.destination
          Chef::Log.debug "#{new_resource} updated working copy #{new_resource.destination} to #{new_resource.repository} revision #{new_resource.revision}"
        end
        c
      end

      def current_repository
        @current_repository ||= repo_attrs["URL"]
      end

      def current_repository_matches_target_repository?
        !current_repository.nil? && (new_resource.repository == current_repository)
      end

      def repo_attrs
        return {} unless ::File.exist?(::File.join(new_resource.destination, ".svn"))

        @repo_attrs ||= svn_info.lines.each_with_object({}) do |line, attrs|
          next unless line =~ SVN_INFO_PATTERN

          property = Regexp.last_match[1]
          value = Regexp.last_match[2]
          attrs[property] = value
        end

        raise "Could not parse `svn info` data: #{svn_info}" if @repo_attrs.empty?

        @repo_attrs
      end

      def svn_info
        command = scm(:info)
        shell_out!(command, run_options(:cwd => cwd, :returns => [0, 1])).stdout
      end

      def revision_int
        @revision_int ||= begin
          if new_resource.revision =~ /^\d+$/
            new_resource.revision
          else
            command = scm(:info, new_resource.repository, new_resource.svn_info_args, authentication, "-r#{new_resource.revision}")
            svn_info = shell_out!(command, run_options(:returns => [0, 1])).stdout

            extract_revision_info(svn_info)
          end
        end
      end
    end
  end
end
