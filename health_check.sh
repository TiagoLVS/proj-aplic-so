#!/bin/bash

# health_check.sh - Script de validação da saúde do laboratório
# Verifica se todas as VMs foram provisionadas corretamente

set -e

echo "============================================================"
echo "🏥 HEALTH CHECK - Laboratório Vagrant + Ansible"
echo "============================================================"
echo ""

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contadores
CHECKS_PASSED=0
CHECKS_FAILED=0

# Função para registrar sucesso
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS_PASSED++))
}

# Função para registrar falha
check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((CHECKS_FAILED++))
}

# Função para registrar warning
check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

echo "1️⃣  Verificando Status das VMs..."
echo ""

# Verifica se as VMs estão rodando
if vagrant status admin-control | grep -q "running"; then
    check_pass "admin-control está rodando"
else
    check_fail "admin-control NÃO está rodando"
fi

if vagrant status gestor-server | grep -q "running"; then
    check_pass "gestor-server está rodando"
else
    check_fail "gestor-server NÃO está rodando"
fi

if vagrant status publico-terminal | grep -q "running"; then
    check_pass "publico-terminal está rodando"
else
    check_fail "publico-terminal NÃO está rodando"
fi

echo ""
echo "2️⃣  Verificando Conectividade Entre VMs (Ping Test)..."
echo ""

# Testa ping entre as máquinas
if vagrant ssh admin-control -c "ping -c 1 192.168.56.11 > /dev/null 2>&1"; then
    check_pass "admin-control consegue atingir gestor-server (192.168.56.11)"
else
    check_fail "admin-control NÃO consegue atingir gestor-server"
fi

if vagrant ssh admin-control -c "ping -c 1 192.168.56.12 > /dev/null 2>&1"; then
    check_pass "admin-control consegue atingir publico-terminal (192.168.56.12)"
else
    check_fail "admin-control NÃO consegue atingir publico-terminal"
fi

echo ""
echo "3️⃣  Verificando Ansible no admin-control..."
echo ""

# Verifica se o Ansible está instalado
if vagrant ssh admin-control -c "ansible --version > /dev/null 2>&1"; then
    check_pass "Ansible está instalado no admin-control"
else
    check_fail "Ansible NÃO está instalado no admin-control"
fi

# Testa ping do Ansible
if vagrant ssh admin-control -c "cd /home/vagrant && ansible all -i inventory.ini -m ping" > /dev/null 2>&1; then
    check_pass "Ansible consegue atingir todos os hosts (ansible ping)"
else
    check_fail "Ansible NÃO consegue atingir todos os hosts"
fi

echo ""
echo "4️⃣  Verificando Usuários no gestor-server..."
echo ""

# Verifica se o usuário gestor_pro foi criado
if vagrant ssh gestor-server -c "id gestor_pro > /dev/null 2>&1"; then
    check_pass "Usuário 'gestor_pro' existe no gestor-server"
else
    check_fail "Usuário 'gestor_pro' NÃO existe no gestor-server"
fi

# Verifica se gestor_pro tem privilégios sudo
if vagrant ssh gestor-server -c "groups gestor_pro | grep -q sudo"; then
    check_pass "Usuário 'gestor_pro' tem privilégios sudo"
else
    check_fail "Usuário 'gestor_pro' NÃO tem privilégios sudo"
fi

echo ""
echo "5️⃣  Verificando Usuários no publico-terminal..."
echo ""

# Verifica se o usuário aluno foi criado
if vagrant ssh publico-terminal -c "id aluno > /dev/null 2>&1"; then
    check_pass "Usuário 'aluno' existe no publico-terminal"
else
    check_fail "Usuário 'aluno' NÃO existe no publico-terminal"
fi

# Verifica se aluno NÃO tem privilégios sudo
if ! vagrant ssh publico-terminal -c "groups aluno | grep -q sudo"; then
    check_pass "Usuário 'aluno' NOT tem privilégios sudo (restrição correta)"
else
    check_fail "Usuário 'aluno' TEM privilégios sudo (deveria ser restrito)"
fi

echo ""
echo "6️⃣  Verificando Interface Gráfica no publico-terminal..."
echo ""

# Verifica se Cinnamon foi instalado
if vagrant ssh publico-terminal -c "dpkg -l | grep -q cinnamon-desktop-environment"; then
    check_pass "Cinnamon Desktop Environment foi instalado"
else
    check_fail "Cinnamon Desktop Environment NÃO foi instalado"
fi

# Verifica se lightdm foi instalado
if vagrant ssh publico-terminal -c "dpkg -l | grep -q lightdm"; then
    check_pass "LightDM Display Manager foi instalado"
else
    check_fail "LightDM Display Manager NÃO foi instalado"
fi

# Verifica se lightdm está rodando
if vagrant ssh publico-terminal -c "systemctl is-active --quiet lightdm"; then
    check_pass "LightDM está rodando"
else
    check_warn "LightDM pode não estar rodando (esperado em ambiente headless)"
fi

echo ""
echo "============================================================"
echo "📊 RELATÓRIO FINAL"
echo "============================================================"
echo -e "Checks passaram: ${GREEN}${CHECKS_PASSED}${NC}"
echo -e "Checks falharam: ${RED}${CHECKS_FAILED}${NC}"
echo ""

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ Laboratório está saudável!${NC}"
    exit 0
else
    echo -e "${RED}✗ Laboratório apresenta problemas. Verifique os erros acima.${NC}"
    exit 1
fi
