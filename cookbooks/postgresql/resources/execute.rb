#
# Cookbook Name:: postgresql
# Resource:: postgresql_execute
#
# Copyright 2012, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default_action :run

actions :nothing, :run

attribute :command, :kind_of => String, :name_attribute => true
attribute :cluster, :kind_of => String, :required => true
attribute :database, :kind_of => String, :required => true
attribute :user, :default => "postgres"
attribute :group, :default => "postgres"
