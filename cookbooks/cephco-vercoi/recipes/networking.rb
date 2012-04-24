package 'ethtool'
package 'bridge-utils'

# this is ugly but let's fight that later

# a true chef person would probably try to put these in node
# attributes, but these are not lovingly crafted nodes, these are
# chef-solo runs, and there's only 8 vercoi machines..

VERCOI_MACS = {
  'vercoi02' => {
    '1g1' => '00:26:6c:fc:3d:a0',
    '1g2' => '00:26:6c:fc:3d:a1',
    '10g1' => '00:8c:fa:00:d6:e2',
    '10g2' => '00:8c:fa:00:d6:e3',
  },
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
  'vercoi01' => {
    'front' => '10.214.128.140',
    'back' => '10.214.144.140',
  },
  'vercoi02' => {
    'front' => '10.214.128.141',
    'back' => '10.214.144.141',
  },
  'vercoi03' => {
    'front' => '10.214.128.142',
    'back' => '10.214.144.142',
  },
  'vercoi04' => {
    'front' => '10.214.128.143',
    'back' => '10.214.144.143',
  },
  'vercoi05' => {
    'front' => '10.214.128.144',
    'back' => '10.214.144.144',
  },
  'vercoi06' => {
    'front' => '10.214.128.145',
    'back' => '10.214.144.145',
  },
  'vercoi07' => {
    'front' => '10.214.128.146',
    'back' => '10.214.144.146',
  },
  'vercoi08' => {
    'front' => '10.214.128.147',
    'back' => '10.214.144.147',
  },
}

cookbook_file '/etc/network/rename-if-by-mac' do
  backup false
  owner 'root'
  group 'root'
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
