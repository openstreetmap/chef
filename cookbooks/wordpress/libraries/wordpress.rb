require "chef/mixin/shell_out"

require "addressable"
require "httpclient"
require "php_serialize"

class Chef
  module Wordpress
    extend Chef::Mixin::ShellOut

    @api_responses = {}
    @svn_responses = {}

    class << self
      def current_version
        core_version_check["offers"].first["current"]
      end

      def current_plugin_version(name)
        if svn_cat("https://plugins.svn.wordpress.org/#{name}/trunk/readme.txt") =~ /Stable tag:\s*([^\s\r]*)[\s\r]*/
          Regexp.last_match[1]
        else
          "trunk"
        end
      end

      private

      def core_version_check
        api_get("https://api.wordpress.org/core/version-check/1.6")
      end

      def api_get(url)
        @api_responses[url] ||= ::PHP.unserialize(::HTTPClient.new.get_content(url))
      end

      def svn_cat(url)
        unless @svn_responses[url]
          result = shell_out!("svn", "cat", url)

          @svn_responses[url] = result.stdout.force_encoding("UTF-8")
        end

        @svn_responses[url]
      end
    end
  end
end
