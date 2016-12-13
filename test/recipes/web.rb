# # encoding: utf-8

# Inspec test for recipe aar_cookbook::web

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

case os['family']
when 'debian'
  apache_package = 'apache2'
when 'redhat'
  apache_package = 'httpd'
end

describe package(apache_package) do
  it { should be_installed }
end

%w(
  python
  libapache2-mod-wsgi
  python-pip
  python-mysqldb
  git
).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe group('www-data') do
  it { should exist }
end

describe user('www-data') do
  it {should exist}
  its('shell') { should eq '/usr/sbin/nologin' }
  its('groups') { should include 'www-data' }
end

describe file('/var/www/AAR') do
  it { should be_directory }
  it { should be_owned_by 'www-data' }
  its('mode') { should cmp '0755' }
end

describe file('/opt/AAR') do
  it { should be_directory }
end

describe file('/var/www/AAR/AAR_config.py') do
  it { should exist }
  it { should be_owned_by 'www-data' }
  its('mode') { should cmp '0644' }
end

describe port(80) do
  it { should be_listening }
end

describe file("/etc/#{apache_package}/sites-enabled/AAR-apache.conf") do
  it { should be_file }
  its('content') { should match(/WSGIDaemonProcess \/AAR user=www-data group=www-data threads=5/) }
  it { should be_owned_by 'root' }
end

describe file ('/etc/apache2/sites-enabled/000-default.conf') do
  it { should_not exist }
end

describe systemd_service(apache_package) do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
