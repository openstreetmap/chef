class Chef
  class Provider
    class RemoteDirectory
      def action_create
        super
        Chef::Log.debug("Doing a remote recursive directory transfer for #{@new_resource}")

        files_transferred = Set.new
        files_to_transfer.each do |cookbook_file_relative_path|
          create_cookbook_file(cookbook_file_relative_path)
          files_transferred << ::File.dirname(::File.join(@new_resource.path, cookbook_file_relative_path))
          files_transferred << ::File.join(@new_resource.path, cookbook_file_relative_path)
        end
        if @new_resource.purge
          files_to_purge = Set.new(
                                   Dir.glob(::File.join(@new_resource.path, '**', '*'), ::File::FNM_DOTMATCH).select do |name|
                                     name !~ /(?:^|#{Regexp.escape(::File::SEPARATOR)})\.\.?$/
                                   end
                                   )
          files_to_purge = files_to_purge - files_transferred
          purge_unmanaged_files(files_to_purge)
        end
      end
    end
  end
end
