# -*- mode: ruby -*-
# vi: set ft=ruby :

# ================================================================================
# LABORATÓRIO VAGRANT + ANSIBLE - Infraestrutura Educacional
# 
# 📋 OBJETIVO:
#    Criar um laboratório local completo com 3 VMs (Debian + Ubuntu) para 
#    ensino de administração de sistemas, controle de acesso (RBAC) e automação 
#    com Ansible.
#
# 🎯 ARQUITETURA:
#    - admin-control: Nó de controle Ansible (Debian 12)
#    - gestor-server: Servidor gerenciado (Ubuntu 24.04 LTS)
#    - publico-terminal: Terminal com GUI (Ubuntu 22.04)
#
# 📖 CONFIGURAÇÃO:
#    Edite o arquivo 'variables.yml' para customizar o ambiente (IPs, RAM, etc)
#
# ⚙️ USO:
#    vagrant up              # Inicia o laboratório
#    ./health_check.sh       # Valida a saúde do ambiente
#    vagrant destroy -f      # Destroi todas as VMs
#
# ================================================================================

Vagrant.configure("2") do |config|

  # ==============================================================================
  # 1. Nó de Controle (Ansible Controller)
  # OS: debian/bookworm64 (Debian 12)
  # 
  # Este é o "master node" responsável por gerenciar e configurar as outras VMs
  # via Ansible. Utiliza Debian 12 por ser extremamente leve e estável.
  # ==============================================================================
  config.vm.define "admin-control" do |admin|
   admin.vm.box = "debian/bookworm64"
   admin.vm.hostname = "admin-control"
   admin.vm.network "private_network", ip: "192.168.56.10"
    
   admin.vm.provider "virtualbox" do |vb|
     vb.name = "admin-control"
     vb.memory = "1024"
     vb.cpus = 1
   end
    
   # Copia arquivos de configuração para a VM
   admin.vm.provision "file", source: "inventory.ini", destination: "/home/vagrant/inventory.ini"
   admin.vm.provision "file", source: "playbook_lab.yml", destination: "/home/vagrant/playbook_lab.yml"

   # Instala Ansible e configura o ambiente
   admin.vm.provision "shell", inline: <<-SHELL
     export DEBIAN_FRONTEND=noninteractive
     apt-get update
     apt-get install -y software-properties-common ansible locales
     locale-gen en_US.UTF-8
     echo 'export LC_ALL=en_US.UTF-8' >> /home/vagrant/.bashrc
     echo 'export LANG=en_US.UTF-8' >> /home/vagrant/.bashrc
     echo "✓ Ansible instalado com sucesso"
   SHELL

   # Executa o playbook automaticamente para provisionar as outras VMs
   # Este step garante que toda a configuração seja aplicada sem intervenção manual
   admin.vm.provision "shell", inline: <<-SHELL
     cd /home/vagrant
     sleep 30  # Aguarda as outras VMs ficarem prontas
     echo "🚀 Executando playbook_lab.yml..."
     ansible-playbook -i inventory.ini playbook_lab.yml -v
     echo "✓ Playbook executado com sucesso!"
   SHELL
  end

  # ==============================================================================
  # 2. Servidor de Trabalho (Managed Node)
  # OS: bento/ubuntu-24.04 (Ubuntu 24.04 LTS)
  # 
  # Servidor gerenciado pelo Ansible. Ubuntu 24.04 é a LTS mais recente. 
  # A box Bento é mantida pela comunidade pois Canonical descontinuou suporte 
  # a Vagrant a partir do 24.04.
  # ==============================================================================
  config.vm.define "gestor-server" do |gestor|
    gestor.vm.box = "bento/ubuntu-24.04"
    gestor.vm.hostname = "gestor-server"
    gestor.vm.network "private_network", ip: "192.168.56.11"
    
    gestor.vm.provider "virtualbox" do |vb|
      vb.name = "gestor-server"
      vb.memory = "2048"
      vb.cpus = 2
    end

    # Provisioning mínimo: apenas aguarda o admin-control fazer o trabalho
    gestor.vm.provision "shell", inline: <<-SHELL
      echo "✓ gestor-server pronto para ser gerenciado pelo Ansible"
    SHELL
  end


  # ==============================================================================
  # 3. Terminal Efêmero (Public Terminal with GUI)
  # OS: ubuntu/jammy64 (Ubuntu 22.04 LTS)
  # 
  # Terminal com interface gráfica para uso educacional. Ubuntu 22.04 oferece
  # suporte excelente a desktop e é altamente estável em ambientes de lab.
  # ==============================================================================
  config.vm.define "publico-terminal" do |publico|
    publico.vm.box = "ubuntu/jammy64"
    publico.vm.hostname = "publico-terminal"
    publico.vm.network "private_network", ip: "192.168.56.12"
    
    publico.vm.provider "virtualbox" do |vb|
      vb.name = "publico-terminal"
      vb.memory = "3072"
      vb.cpus = 2
      
      # Ativa a interface gráfica (GUI) no VirtualBox
      vb.gui = true
      vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    end

    # Provisioning mínimo: apenas aguarda o admin-control fazer o trabalho
    publico.vm.provision "shell", inline: <<-SHELL
      echo "✓ publico-terminal pronto para ser gerenciado pelo Ansible"
    SHELL
  end

end

