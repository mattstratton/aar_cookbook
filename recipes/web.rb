#
# Cookbook Name:: aar_cookbook
# Recipe:: web
#
# Copyright 2016 Matt Stratton
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

case node['platform_family']
when 'debian'
  apache_package = 'apache2'
when 'rhel'
  apache_package = 'httpd'
else Chef::Log.fatal("The platform family #{node['platform_family']} is not supported")
end

package apache_package do
  action :install
end

if apache_package == 'httpd'
  directory "/etc/#{apache_package}/sites-enabled/" do
    action :create
  end
end

config_content = <<-EOH
<VirtualHost *:80>
  ServerName /
</VirtualHost>
EOH

file "/etc/#{apache_package}/sites-enabled/AAR-apache.conf" do
  content config_content
  action :create
end

service apache_package do
  action [:enable, :start]
end
