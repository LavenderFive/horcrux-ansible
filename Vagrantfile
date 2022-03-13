Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.define "signer1" do |signer|
        signer.vm.box = "ubuntu/focal64"
        signer.vm.network "private_network", ip: "10.168.1.10"
        signer.vm.hostname= "signer1"
    end
    config.vm.define "signer2" do |ubuntu|
        ubuntu.vm.box = "ubuntu/focal64"
        ubuntu.vm.network "private_network", ip: "10.168.1.11"
        ubuntu.vm.hostname= "signer2"
    end
    config.vm.define "signer3" do |ubuntu|
        ubuntu.vm.box = "ubuntu/focal64"
        ubuntu.vm.network "private_network", ip: "10.168.1.12"
        ubuntu.vm.hostname= "signer3"
    end
end
