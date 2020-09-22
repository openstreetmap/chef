module OpenStreetMap
  module Provider
    module Git
      def git(*args, **run_opts)
        args.push("--force") if args.first == "fetch" && args.last == "--tags"

        super(args, **run_opts)
      end
    end
  end
end

Chef::Provider::Git.prepend(OpenStreetMap::Provider::Git)
