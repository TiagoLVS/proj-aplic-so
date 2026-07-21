# -*- mode: ruby -*-
# vi: set ft=ruby :

# Objetivo: Criação de um laboratório local utilizando Vagrant com distribuições 
# estritamente baseadas em Debian (Debian e Ubuntu). Isso garante total compatibilidade
# com o gerenciador de pacotes 'apt' em todo o ambiente, além de padronizar a 
# administração dos sistemas.

Vagrant.configure("2") do |config|

  # ==============================================================================
  # 1. Nó de Controle (Usuário Administrador)
  # OS: debian/bookworm64 (Debian 12)
  # 
  # Justificativa da escolha: O Debian 12 (Bookworm) oferece uma base extremamente 
  # estável, minimalista e leve. É o sistema ideal para atuar como o nó de controle 
  # (controller node) do Ansible sem desperdiçar recursos do host, garantindo 
  # alta confiabilidade e total compatibilidade com os padrões Debian/apt.
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
    
    # Provisionador File: Copia o inventário do Host para o admin-control
    admin.vm.provision "file", source: "inventory.ini", destination: "/home/vagrant/inventory.ini"
    
    # Quando os playbooks forem criados em uma pasta local 'playbooks/', 
    # descomente a linha abaixo para que o Vagrant também os copie para a VM:
    admin.vm.provision "file", source: "playbook_lab.yml", destination: "/home/vagrant/playbook_lab.yml"

    # Provisionamento Shell: Instala o Ansible no momento do boot
    # O comando 'apt-get update' é necessário para garantir que os repositórios 
    # locais estão atualizados antes de instalar novos pacotes.
    admin.vm.provision "shell", inline: <<-SHELL
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y software-properties-common ansible
      echo "Ansible instalado com sucesso no nó de controle."
    SHELL
  end


  # ==============================================================================
  # 2. Servidor de Trabalho (Usuário Gestor)
  # OS: ubuntu/noble64 (Ubuntu 24.04 LTS)
  # 
  # Justificativa da escolha: O Ubuntu 24.04 (Noble Numbat) é a versão Long Term 
  # Support (LTS) mais recente da Canonical. Ele traz as versões mais modernas de 
  # pacotes e bibliotecas necessárias para rodar serviços de backend e ferramentas 
  # profissionais, mantendo a compatibilidade do apt e uma robusta política de segurança.
  # ==============================================================================
  config.vm.define "gestor-server" do |gestor|
    gestor.vm.box = "ubuntu/noble64"
    gestor.vm.hostname = "gestor-server"
    gestor.vm.network "private_network", ip: "192.168.56.11"
    
    gestor.vm.provider "virtualbox" do |vb|
      vb.name = "gestor-server"
      vb.memory = "2048"
      vb.cpus = 2
      # Mantém sem interface gráfica (headless) por padrão (vb.gui = false é o default)
    end
  end


  # ==============================================================================
  # 3. Terminal Efêmero (Usuário Comum / Público Geral)
  # OS: ubuntu/jammy64 (Ubuntu 22.04 LTS)
  # 
  # Justificativa da escolha: O Ubuntu 22.04 (Jammy Jellyfish) é uma versão LTS
  # altamente madura e amplamente testada para ambientes de desktop. Possui um 
  # excelente e vasto suporte a pacotes com interface gráfica (GUI), garantindo 
  # uma experiência visual fluida, sem bugs recentes e muito estável para o usuário final.
  # ==============================================================================
  config.vm.define "publico-terminal" do |publico|
    publico.vm.box = "ubuntu/jammy64"
    publico.vm.hostname = "publico-terminal"
    publico.vm.network "private_network", ip: "192.168.56.12"
    
    publico.vm.provider "virtualbox" do |vb|
      vb.name = "publico-terminal"
      vb.memory = "3072"
      vb.cpus = 2
      
      # Requisito Especial: Ativa a interface gráfica (GUI) no VirtualBox
      # Isso permitirá que o ambiente desktop seja exibido diretamente na tela do host
      vb.gui = true
    end
  end

end
