Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "private_network", type: "dhcp"                            ## auto-setup a private ip
  config.vm.network :forwarded_port, guest: 22, host: 22, auto_correct: true   ## avoiding port collision errors ...
                                                                               ## ...as sometimes, vagrant can't recover on its own
  ## provisioning via 'puppet'. 
  config.vm.provision :puppet do |puppet|
      puppet.manifests_path = 'puppet/manifests'
      puppet.module_path = 'puppet/modules'
     puppet.manifest_file = 'init.pp'
  end
end
