#!/bin/bash

# quick_start.sh - Script de inicialização rápida do laboratório
# Fornece um menu interativo para operações comuns

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_menu() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}     🏢 LABORATÓRIO VAGRANT + ANSIBLE - Menu Rápido     ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "1️⃣  Iniciar o laboratório (vagrant up)"
    echo "2️⃣  Parar o laboratório (vagrant halt)"
    echo "3️⃣  Suspender o laboratório (vagrant suspend)"
    echo "4️⃣  Acordar o laboratório (vagrant resume)"
    echo "5️⃣  Destruir o laboratório (vagrant destroy)"
    echo ""
    echo "6️⃣  Conectar ao admin-control (SSH)"
    echo "7️⃣  Conectar ao gestor-server (SSH)"
    echo "8️⃣  Conectar ao publico-terminal (SSH)"
    echo ""
    echo "9️⃣  Verificar saúde do laboratório (Health Check)"
    echo "🔟 Ver status das VMs"
    echo ""
    echo "1️⃣1️⃣ Executar playbook manualmente"
    echo "1️⃣2️⃣ Validar Vagrantfile"
    echo ""
    echo "0️⃣  Sair"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Menu principal
while true; do
    show_menu
    read -p "Escolha uma opção: " choice
    
    case $choice in
        1)
            echo ""
            echo -e "${GREEN}🚀 Iniciando o laboratório...${NC}"
            vagrant up
            echo -e "${GREEN}✓ Laboratório iniciado com sucesso!${NC}"
            ;;
        2)
            echo ""
            echo -e "${YELLOW}⏸️  Parando o laboratório...${NC}"
            vagrant halt
            echo -e "${GREEN}✓ Laboratório parado!${NC}"
            ;;
        3)
            echo ""
            echo -e "${YELLOW}💤 Suspendendo o laboratório...${NC}"
            vagrant suspend
            echo -e "${GREEN}✓ Laboratório suspenso!${NC}"
            ;;
        4)
            echo ""
            echo -e "${GREEN}⏰ Acordando o laboratório...${NC}"
            vagrant resume
            echo -e "${GREEN}✓ Laboratório acordado!${NC}"
            ;;
        5)
            echo ""
            read -p "Tem certeza? Isso destruirá todas as VMs [y/N]: " confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                echo -e "${RED}🗑️  Destruindo o laboratório...${NC}"
                vagrant destroy -f
                echo -e "${GREEN}✓ Laboratório destruído!${NC}"
            else
                echo "Cancelado!"
            fi
            ;;
        6)
            echo ""
            echo -e "${BLUE}🔌 Conectando ao admin-control...${NC}"
            vagrant ssh admin-control
            ;;
        7)
            echo ""
            echo -e "${BLUE}🔌 Conectando ao gestor-server...${NC}"
            vagrant ssh gestor-server
            ;;
        8)
            echo ""
            echo -e "${BLUE}🔌 Conectando ao publico-terminal...${NC}"
            vagrant ssh publico-terminal
            ;;
        9)
            echo ""
            echo -e "${GREEN}🏥 Executando Health Check...${NC}"
            if [ -f "./health_check.sh" ]; then
                bash ./health_check.sh
            else
                echo -e "${RED}✗ Arquivo health_check.sh não encontrado!${NC}"
            fi
            ;;
        10)
            echo ""
            echo -e "${BLUE}📊 Status das VMs:${NC}"
            vagrant status
            ;;
        11)
            echo ""
            read -p "Executar playbook em qual host? (gestores/publico/all) [all]: " host
            host=${host:-all}
            echo -e "${GREEN}▶️  Executando playbook...${NC}"
            vagrant ssh admin-control -c "cd /home/vagrant && ansible-playbook -i inventory.ini playbook_lab.yml -v"
            ;;
        12)
            echo ""
            echo -e "${BLUE}🔍 Validando Vagrantfile...${NC}"
            vagrant validate
            echo -e "${GREEN}✓ Vagrantfile válido!${NC}"
            ;;
        0)
            echo ""
            echo -e "${GREEN}Até logo! 👋${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opção inválida! Tente novamente.${NC}"
            ;;
    esac
    
    echo ""
    read -p "Pressione ENTER para continuar..."
done
