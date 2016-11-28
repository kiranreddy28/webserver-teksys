#
# Cookbook Name:: webserver
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


unless %w(rhel debian).include?node['platform_family']
  raise 'Platform family not supported by this cookbook'
end
apache_vhost_conf_dir = node['apache_vhost_conf_dir']

package 'apache' do
  package_name node['apache_package']
  action :install
end

if node['platform_family'] == 'rhel'
  package 'ssl module' do
    package_name node['apache_ssl_module_package']
    action :install
  end
end

directory "#{node['apache_dir']}/ssl" do
  action :create
end

execute 'generate ssl certificate' do
  command "openssl req -x509 -nodes -days 1095 -newkey rsa:2048 -out #{node['apache_dir']}/ssl/server.crt -keyout #{node['apache_dir']}/ssl/server.key -subj '/CN=#{node['fqdn']}'"
  not_if { File.exists?("#{node['apache_dir']}/ssl/server.crt") }
end

file "#{node['apache_vhost_conf_dir']}/ssl.conf" do
  content "LoadModule rewrite_module modules/mod_rewrite.so
LoadModule ssl_module modules/mod_ssl.so
Listen 443 https

RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}

<VirtualHost *:443>
DocumentRoot /var/www/html
ServerName #{node['fqdn']}
SSLEngine on
SSLCertificateFile #{node['apache_dir']}/ssl/server.crt
SSLCertificateKeyFile #{node['apache_dir']}/ssl/server.key
</VirtualHost>"
end

file '/var/www/html/index.html' do
  content '<html>
  <head>
    <title>Hello World</title>
  </head>
  <body>
    <h1>Hello World!</h1>
  </body>
</html>'
  owner 'root'
  group 'root'
  mode '644'
  action :create
end

service 'apache' do
  service_name node['apache_service']
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start, :restart]
end
