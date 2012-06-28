# workaround for bug https://bugs.launchpad.net/ubuntu/+source/libvirt/+bug/1018956
execute 'set up libvirt pool default' do
  command <<-'EOH'
    set -e
    if ! virsh pool-uuid default >/dev/null 2>/dev/null; then
      # does not exist
      virsh pool-define-as --name default dir --target /var/lib/libvirt/images
    fi
    virsh -q pool-info default | while read line; do
      case "$line" in
        State:\ *inactive)
          virsh pool-start default
          ;;
        Autostart:\ *no)
          virsh pool-autostart default
          ;;
      esac
    done
  EOH
end

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


# TODO refactor into a libvirt_interface LWR?
[0, 1, 2, 3, 4, 5, 6, 7, 8, 9].each do |num|

  template "/srv/chef/libvirt-net-isolated#{num}.xml" do
    source 'libvirt-net-isolated.xml.erb'
    owner 'root'
    group 'root'
    mode 0644
    variables(
              'name' => "isolated#{num}",
              )
  end

  execute "set up libvirt network isolated#{num}" do
    environment ({
                   'NET' => "isolated#{num}",
                 })
    command <<-'EOH'
      set -e
      if ! virsh net-uuid "$NET" >/dev/null 2>/dev/null; then
        # does not exist
        virsh net-define /srv/chef/libvirt-net-"$NET".xml
      fi
      virsh -q net-info "$NET" | while read line; do
        case "$line" in
          Active:\ *no)
            virsh net-start "$NET"
            ;;
          Autostart:\ *no)
            virsh net-autostart "$NET"
            ;;
        esac
      done
    EOH
  end

end
