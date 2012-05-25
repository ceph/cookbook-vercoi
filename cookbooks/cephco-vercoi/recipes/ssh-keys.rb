directory '/home/ubuntu/.ssh' do
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
end

ruby_block "set up ssh keys" do
  block do
    names = data_bag('ssh-keys')
    f = File.open('/home/ubuntu/.ssh/authorized_keys.chef', 'w') do |f|
      names.each do |name|
        data = data_bag_item('ssh-keys', name)
        f.puts(data['key'])
      end
    end
  end
end

execute "merge authorized ssh keys" do
  command <<-'EOH'
    set -e
    set -- ~ubuntu/.ssh/authorized_keys.chef
    if [ -e ~ubuntu/.ssh/authorized_keys ]; then
      set -- "$@" ~ubuntu/.ssh/authorized_keys
    fi
    sort -u -o ~ubuntu/.ssh/authorized_keys.tmp -- "$@"
    chown ubuntu:ubuntu -- ~ubuntu/.ssh/authorized_keys.tmp
    mv -- ~ubuntu/.ssh/authorized_keys.tmp ~ubuntu/.ssh/authorized_keys
  EOH
end

