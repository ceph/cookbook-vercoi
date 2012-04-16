package 'ethtool'
package 'bridge-utils'

# this is ugly but let's fight that later

# a true chef person would probably try to put these in node
# attributes, but these are not lovingly crafted nodes, these are
# chef-solo runs, and there's only 8 vercoi machines..

VERCOI_MACS = {
  'vercoi04' => {
    '1g1' => '00:a0:d1:ec:77:24',
    '1g2' => '00:a0:d1:ec:77:25',
    '10g1' => '00:8c:fa:00:d7:4c',
    '10g2' => '00:8c:fa:00:d7:4d',
  },
  'vercoi05' => {
    '1g1' => '00:26:6c:fc:3b:70',
    '1g2' => '00:26:6c:fc:3b:71',
    '10g1' => '00:8c:fa:00:d7:2a',
    '10g2' => '00:8c:fa:00:d7:2b',
  },
}

VERCOI_IPS = {
  'vercoi04' => {
    'front' => '10.214.128.143',
    'back' => '10.214.144.143',
  },
  'vercoi05' => {
    'front' => '10.214.128.144',
    'back' => '10.214.144.144',
  },
}

file '/etc/network/rename-if-by-mac' do
  mode 0755
end


# generate a .chef file from a template, and then be extra careful in
# swapping it in place; effecting changes over ssh is DANGEROUS,
# please have a serial console handy
template '/etc/network/interfaces.chef' do
  source 'interfaces.erb'
  mode 0644
  variables(
            'macs' => VERCOI_MACS[node['hostname']],
            'ips' => VERCOI_IPS[node['hostname']],
            )
end

execute "activate network config" do
   command <<-'EOH'
     set -e
     ifdown -a
     mv /etc/network/interfaces.chef /etc/network/interfaces
     ifup -a
  EOH
  # don't run the ifdown/ifup if there's no change to the file
  not_if "cmp /etc/network/interfaces.chef /etc/network/interfaces"
end
