directory '/srv/chef' do
  owner 'root'
  group 'root'
  mode 0755
end

cookbook_file '/srv/chef/libvirt-net-pub.xml' do
  owner 'root'
  group 'root'
  mode 0644
end

execute 'set up libvirt network pub' do
  command <<-'EOH'
    set -e
    virsh net-define /srv/chef/libvirt-net-pub.xml
    virsh net-autostart pub
    virsh net-start pub
  EOH
end

execute 'allow libvirt for user ubuntu' do
  command <<-'EOH'
    set -e
    gpasswd -a ubuntu libvirtd
  EOH
end
