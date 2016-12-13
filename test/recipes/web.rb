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

describe port(80) do
  it { should be_listening }
end

describe file("/etc/#{apache_package}/sites-enabled/AAR-apache.conf") do
  it { should be_file }
  its('content') { should match(/ServerName/) }
  it { should be_owned_by 'root' }
end

describe systemd_service(apache_package) do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
