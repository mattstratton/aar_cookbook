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

apt_update 'update' if platform_family?('debian')

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

%w(
  python
  libapache2-mod-wsgi
  python-pip
  python-mysqldb
  git
).each do |p|
  package p do
    action :install
  end
end

if apache_package == 'httpd'
  directory "/etc/#{apache_package}/sites-enabled/" do
    action :create
  end
end

group node['aar_cookbook']['web_group'] do
  action :create
end

user node['aar_cookbook']['web_user'] do
  system true
  shell '/usr/sbin/nologin'
end

directory node['aar_cookbook']['web_dir'] do
  owner node['aar_cookbook']['web_user']
  group node['aar_cookbook']['web_group']
  mode '0755'
  recursive true
end

directory node['aar_cookbook']['source_code_directory'] do
  action :create
  recursive true
end

git node['aar_cookbook']['source_code_directory'] do
  repository 'https://github.com/mattstratton/Awesome-Appliance-Repair.git'
  revision 'master'
  action :sync
  notifies :run, 'execute[copy_aar-code]', :immediately
end

execute 'copy_aar-code' do
  command "cp -r #{node['aar_cookbook']['source_code_directory']}/AAR/. #{node['aar_cookbook']['web_dir']}"
  action :nothing
end

template "#{node['aar_cookbook']['web_dir']}/AAR_config.py" do
  source 'AAR_config.py.erb'
  owner node['aar_cookbook']['web_user']
  group node['aar_cookbook']['web_group']
  mode '0644'
end

service apache_package do
  supports :restart => true
  action [:enable, :start]
end

execute 'remove_default_apache' do
  command 'rm /etc/apache2/sites-enabled/000-default.conf'
  only_if do
    File.exist?('/etc/apache2/sites-enabled/000-default.conf')
  end
  notifies :restart, "service[#{apache_package}]"
end

template "/etc/#{apache_package}/sites-enabled/#{node['aar_cookbook']['apache_config_file']}" do
  source 'AAR-apache.conf.erb'
  action :create
  notifies :restart, "service[#{apache_package}]"
end
