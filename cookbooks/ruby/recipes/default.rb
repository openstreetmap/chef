#
# Cookbook:: ruby
# Recipe:: default
#
# Copyright:: 2022, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ruby_version = node[:ruby][:version]

if node[:ruby][:fullstaq]

  include_recipe "apt::fullstaq-ruby"

  package %W[
    fullstaq-ruby-common
    fullstaq-ruby-#{ruby_version}-jemalloc
  ]

  %w[bundle bundler erb gem irb racc rake rbs rdbg rdoc ri ruby syntax_suggest typeproc].each do |command|
    link "/usr/local/bin/#{command}" do
      to "/usr/lib/fullstaq-ruby/versions/#{ruby_version}-jemalloc/bin/#{command}"
      owner "root"
      group "root"
    end
  end

else

  package %w[
    ruby
    ruby-dev
    ruby-bundler
  ]

end
