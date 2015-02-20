require "chef/mixin/command"

class Chef
  module Wordpress
    extend Chef::Mixin::Command

    @api_responses = {}
    @svn_responses = {}

    def self.current_version
      core_version_check["offers"].first["current"]
    end

    def self.current_plugin_version(name)
      if svn_cat("http://plugins.svn.wordpress.org/#{name}/trunk/readme.txt") =~ /Stable tag:\s*([^\s\r]*)[\s\r]*/
        Regexp.last_match[1]
      else
        "trunk"
      end
    end

    private

    def self.core_version_check
      api_get("http://api.wordpress.org/core/version-check/1.6")
    end

    def self.api_get(url)
      @api_responses[url] ||= ::PHP.unserialize(::HTTPClient.new.get_content(url))
    end

    def self.svn_cat(url)
      unless @svn_responses[url]
        status, stdout, stderr = output_of_command("svn cat #{url}", {})
        handle_command_failures(status, "STDOUT: #{stdout}\nSTDERR: #{stderr}", :output_on_failure => true)

        @svn_responses[url] = stdout.force_encoding("UTF-8")
      end

      @svn_responses[url]
    end
  end
end
