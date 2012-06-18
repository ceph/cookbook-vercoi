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
    if ! virsh net-uuid pub >/dev/null 2>/dev/null; then
      # does not exist
      virsh net-define /srv/chef/libvirt-net-pub.xml
    fi
    virsh -q net-info pub | while read line; do
      case "$line" in
        Active:\ *no)
          virsh net-start pub
          ;;
        Autostart:\ *no)
          virsh net-autostart pub
          ;;
      esac
    done
  EOH
end

cookbook_file '/srv/chef/libvirt-net-front.xml' do
  owner 'root'
  group 'root'
  mode 0644
end

execute 'set up libvirt network front' do
  command <<-'EOH'
    set -e
    if ! virsh net-uuid front >/dev/null 2>/dev/null; then
      # does not exist
      virsh net-define /srv/chef/libvirt-net-front.xml
    fi
    virsh -q net-info front | while read line; do
      case "$line" in
        Active:\ *no)
          virsh net-start front
          ;;
        Autostart:\ *no)
          virsh net-autostart front
          ;;
      esac
    done
  EOH
end

execute 'allow libvirt for user ubuntu' do
  command <<-'EOH'
    set -e
    gpasswd -a ubuntu libvirtd
  EOH
end
