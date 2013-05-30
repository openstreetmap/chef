class Chef
  class Provider
    class Git
      def remote_resolve_reference
        Chef::Log.debug("#{@new_resource} resolving remote reference")
        command = git('ls-remote', @new_resource.repository, @new_resource.revision, "#{@new_resource.revision}^{}")
        @resolved_reference = shell_out!(command, run_options).stdout.split("\n").last
        if  @resolved_reference =~ /^([0-9a-f]{40})\s+(\S+)/
          $1
        else
          nil
        end
      end
    end
  end
end
