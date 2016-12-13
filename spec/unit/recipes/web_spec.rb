#
# Cookbook Name:: aar_cookbook
# Spec:: default
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

require 'spec_helper'

describe 'aar_cookbook::web' do
  context 'On Ubuntu 16.04' do
    let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04').converge(described_recipe) }

    it 'installs apache2' do
      expect(chef_run).to install_package('apache2')
    end
    it 'creates the AAR configuration file for apache' do
      expect(chef_run).to create_file('/etc/apache2/sites-enabled/AAR-apache.conf')
    end
    it 'starts and enables the apache2 service' do
      expect(chef_run).to start_service('apache2')
      expect(chef_run).to enable_service('apache2')
    end
  end

  context 'on CentOS 7' do
    let(:chef_run) { ChefSpec::ServerRunner.new(platform: 'centos', version: '7.2.1511').converge(described_recipe) }

    it 'installs httpd' do
      expect(chef_run).to install_package('httpd')
    end
    it 'creates the AAR configuration file for apache' do
      expect(chef_run).to create_file('/etc/httpd/sites-enabled/AAR-apache.conf')
    end
    it 'starts and enables the httpd service' do
      expect(chef_run).to start_service('httpd')
      expect(chef_run).to enable_service('httpd')
    end
  end
end
