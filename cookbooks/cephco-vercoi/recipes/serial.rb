execute "enable kernel logging to console" do
  command <<-'EOH'
    set -e
    f=/etc/default/grub

    # if it has a setting, make sure it's to ttyS1
    if grep -q '^GRUB_CMDLINE_LINUX=.*".*console=tty0 console=ttyS[01],115200' $f; then sed 's/console=ttyS[01]/console=ttyS1/' <$f >$f.chef; fi

    # if it has no setting, add it
    if ! grep -q '^GRUB_CMDLINE_LINUX=.*".* console=tty0 console=ttyS[01],115200.*' $f; then sed 's/^GRUB_CMDLINE_LINUX="\(.*\)"$/GRUB_CMDLINE_LINUX="\1 console=tty0 console=ttyS1,115200"/' <$f >$f.chef; fi

    # if we did something; move it into place.  update-grub done below.
    if [ -f $f.chef ] ; then mv $f.chef $f; fi
  EOH
end

execute 'update-grub' do
end

cookbook_file '/etc/init/ttyS1.conf' do
   source 'ttyS1.conf'
   mode 0644
   owner "root"
   group "root"
   notifies :start, "service[ttyS1]"
end

service "ttyS1" do
  # Default provider for Ubuntu is Debian, and :enable doesn't work
  # for Upstart services unless we change provider.  Assume Upstart
  provider Chef::Provider::Service::Upstart
  action [:enable,:start]
end
