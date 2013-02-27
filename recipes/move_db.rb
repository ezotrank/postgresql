# cat /etc/postgresql/9.2/main/postgresql.conf |grep data_directory|cut -f 2 -d = -s|sed -e "s/\(\s*\)\?'//g"

if node['postgresql']['config']['data_directory'] && ! (::File.exist?(node['postgresql']['config']['data_directory']))
  directory node['postgresql']['config']['data_directory'] do
    owner "postgres"
    group "postgres"
    mode 00700
    action :create
    recursive true
    notifies :stop, 'service[postgresql]', :immediately
  end

  bash "copy pg data" do
    user 'root'
    code <<-EOH
      cp -rf /var/lib/postgresql/#{node['postgresql']['version']}/main/* #{node['postgresql']['config']['data_directory']} && \
      chown -R postgres:postgres #{node['postgresql']['config']['data_directory']}
    EOH
  end

end
