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

package 'apache2' do
  action :install
end

config_content = <<-EOH
<VirtualHost *:80>
  ServerName /
  WSGIDaemonProcess /AAR user=www-data group=www-data threads=5
  WSGIProcessGroup /AAR
  WSGIScriptAlias / /var/www/AAR/awesomeapp.wsgi
  <Directory /var/www/AAR>
    WSGIApplicationGroup %{GLOBAL}
    WSGIScriptReloading On
    Order deny,allow
    Allow from all
  </Directory>

  CustomLog ${APACHE_LOG_DIR}/access.log combined
  ServerAdmin ops@example.com
</VirtualHost>
EOH

file '/etc/apache2/sites-enabled/AAR-apache.conf' do
  content config_content
  action :create
end

service 'apache2' do
  action [ :enable, :start ]
end
