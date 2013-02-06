rpm_package = case node['kernel']['machine']
              when 'x86_64'
                "http://yum.postgresql.org/9.1/redhat/rhel-6-x86_64/pgdg-centos91-9.1-4.noarch.rpm"
              else
                "http://yum.postgresql.org/9.1/redhat/rhel-6-x86_64/pgdg-centos91-9.1-4.noarch.rpm"
              end
execute "rpm -U #{rpm_package}" do
  not_if { ::FileTest.exist? ("/etc/yum.repos.d/pgdg-#{node['postgresql']['version'].split('.').join}-centos.repo") }
end
