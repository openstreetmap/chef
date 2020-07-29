require "digest"

class Chef
  module Mixin
    module PersistentToken
      def persistent_token(*args)
        sha256 = Digest::SHA256.new
        sha256.update(node[:machine_id])
        args.each do |arg|
          sha256.update(arg)
        end
        sha256.hexdigest
      end
    end
  end

  class Recipe
    include Chef::Mixin::PersistentToken
  end
end
