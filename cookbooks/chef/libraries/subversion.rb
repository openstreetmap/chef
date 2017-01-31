require "chef/mixin/shell_out"

class Chef
  class Provider
    class Subversion
      extend Chef::Mixin::ShellOut

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
        @current_repository ||= repo_attrs["URL"]
      end

      def current_repository_matches_target_repository?
        !current_repository.nil? && (@new_resource.repository == current_repository)
      end

      def repo_attrs
        return {} unless ::File.exist?(::File.join(@new_resource.destination, ".svn"))

        @repo_attrs ||= svn_info.lines.each_with_object({}) do |line, attrs|
          raise "Could not parse `svn info` data: #{line}" unless line =~ SVN_INFO_PATTERN

          property = Regexp.last_match[1]
          value = Regexp.last_match[2]
          attrs[property] = value
        end
      end

      def svn_info
        command = scm(:info)
        shell_out!(command, run_options(:cwd => cwd)).stdout
      end
    end
  end
end
