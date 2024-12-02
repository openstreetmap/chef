require "chef/mixin/shell_out"

require "addressable"
require "httpclient"
require "json"

class Chef
  module Wordpress
    extend Chef::Mixin::ShellOut

    @api_responses = {}

    class << self
      def current_version
        core_version_check["offers"].first["current"]
      end

      def current_plugin_version(name)
        plugin_information(name)["version"]
      end

      private

      def core_version_check
        api_get("https://api.wordpress.org/core/version-check/1.7")
      end

      def plugin_information(name)
        api_get("https://api.wordpress.org/plugins/info/1.2/?action=plugin_information&request[slug]=#{name}")
      end

      def api_get(url)
        http_client = ::HTTPClient.new
        http_client.ssl_config.set_trust_ca("/etc/ssl/certs/ca-certificates.crt")
        @api_responses[url] ||= ::JSON.parse(http_client.get_content(url))
      end
    end
  end
end
