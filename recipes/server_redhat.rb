#
# Cookbook Name:: postgresql
# Recipe:: server
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Lamont Granquist (<lamont@opscode.com>)
# Copyright 2009-2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "postgresql::pgdg"
include_recipe "postgresql::client"

# Create a group and user like the package will.
# Otherwise the templates fail.

group "postgres" do
  gid 26
end

user "postgres" do
  shell "/bin/bash"
  comment "PostgreSQL Server"
  home "/var/lib/pgsql"
  gid "postgres"
  system true
  uid 26
  supports :manage_home => false
end

case node['platform_family']
when "rhel"
  package "postgresql#{node['postgresql']['version'].split('.').join}-server"
when "fedora", "suse"
  package "postgresql-server"
end

rpm_package = case node['kernel']['machine']
              when 'x86_64'
                "http://yum.postgresql.org/9.1/redhat/rhel-6-x86_64/pgdg-centos91-9.1-4.noarch.rpm"
              else
                "http://yum.postgresql.org/9.1/redhat/rhel-6-x86_64/pgdg-centos91-9.1-4.noarch.rpm"
              end
execute "rpm -U #{rpm_package}" do
  not_if { ::FileTest.exist? ("/etc/yum.repos.d/pgdg-#{node['postgresql']['version'].split('.').join}-centos.repo") }
end

node['postgresql']['server']['packages'].each do |pg_pack|
  package pg_pack
end

execute "/sbin/service #{node['postgresql']['server']['service_name']}-9.1 initdb" do
  not_if { ::FileTest.exist?(File.join(node['postgresql']['dir'], "PG_VERSION")) }
end

link "/usr/sbin/pg_config" do
  to "/usr/pgsql-9.1/bin/pg_config"
end

service "postgresql" do
  service_name "#{node['postgresql']['server']['service_name']}-9.1"
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

