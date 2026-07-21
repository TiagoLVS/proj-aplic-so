# 🏢 Laboratório Vagrant + Ansible

Um ambiente educacional completo para aprender sobre **administração de sistemas**, **RBAC (Role-Based Access Control)** e **automação com Ansible**, utilizando máquinas virtuais Debian/Ubuntu.

## 📋 O que é este projeto?

Este laboratório cria automaticamente **3 máquinas virtuais Linux** interconectadas:

| VM | SO | Tipo | IP | RAM | CPU | Descrição |
|----|----|----|----|----|-----|-----------|
| **admin-control** | Debian 12 | Headless | 192.168.56.10 | 1GB | 1 | Nó de controle Ansible |
| **gestor-server** | Ubuntu 24.04 LTS | Headless | 192.168.56.11 | 2GB | 2 | Servidor gerenciado |
| **publico-terminal** | Ubuntu 22.04 | GUI | 192.168.56.12 | 3GB | 2 | Terminal com interface gráfica |

## 🚀 Como começar

### Pré-requisitos
- [Vagrant](https://www.vagrantup.com/) instalado
- [VirtualBox](https://www.virtualbox.org/) instalado
- Pelo menos 6GB de RAM disponível (1+2+3 das VMs)
- ~15GB de espaço em disco

### Iniciar o laboratório

```bash
# Dentro do diretório do projeto
vagrant up
```

Isso irá:
1. Baixar as boxes Vagrant (primeira execução demora mais)
2. Criar as 3 VMs
3. Instalar Ansible no admin-control
4. Executar automaticamente o playbook de configuração
5. Criar os usuários e configurar as permissões

⏱️ **Tempo estimado**: 5-10 minutos na primeira execução

### Validar a saúde do laboratório

```bash
./health_check.sh
```

Este script verifica:
- ✓ Se todas as VMs estão rodando
- ✓ Conectividade entre as VMs
- ✓ Se Ansible está funcionando corretamente
- ✓ Se os usuários foram criados com permissões corretas
- ✓ Se a interface gráfica foi instalada

## 📖 Arquitetura e Fluxo

```
┌─────────────────────────────────────────────────────────┐
│                   HOST MACHINE                          │
│                  (Seu Computador)                       │
└─────────────────────────────────────────────────────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
         ┌─────────┐  ┌─────────┐  ┌─────────────┐
         │  admin  │  │ gestor  │  │   publico   │
         │ control │  │ server  │  │  terminal   │
         └─────────┘  └─────────┘  └─────────────┘
         │ Debian 12│  │Ubuntu24│  │ Ubuntu 22   │
         │Headless │  │Headless│  │  + GUI      │
         └─────────┘  └─────────┘  └─────────────┘
              ▲            ▲            ▲
              │            │            │
              └────────────┼────────────┘
                    ansible ssh
                  gerencia as outras
                    duas máquinas
```

## 👥 Usuários Criados

### No `gestor-server`
- **Usuário**: `gestor_pro`
- **Permissões**: Privilégios de administrador (grupo `sudo`)
- **Uso**: Gerenciamento do servidor

### No `publico-terminal`
- **Usuário**: `aluno`
- **Permissões**: Restrito (SEM privilégios sudo)
- **Uso**: Uso educacional com permissões limitadas

## ⚙️ Customização

### Editar configurações

Abra o arquivo `variables.yml` para customizar:

```yaml
# Exemplo: Mudar quantidade de RAM do gestor-server
vms:
  gestor:
    memory: 4096  # Mudar de 2048 para 4096 MB
```

Depois, recrie as VMs:
```bash
vagrant destroy -f
vagrant up
```

### Trocar ambiente gráfico

No `variables.yml`, altere:
```yaml
desktop:
  environment: "kde"  # Opções: cinnamon, kde, gnome
```

## 📝 Comandos Úteis

```bash
# Iniciar o laboratório
vagrant up

# Parar temporariamente as VMs (mantém estado)
vagrant halt

# Suspender as VMs (economy mode)
vagrant suspend

# Acordar as VMs suspensas
vagrant resume

# Destruir as VMs completamente
vagrant destroy -f

# Conectar via SSH ao admin-control
vagrant ssh admin-control

# Conectar ao gestor-server
vagrant ssh gestor-server

# Conectar ao publico-terminal
vagrant ssh publico-terminal

# Ver status de todas as VMs
vagrant status

# Verificar saúde do laboratório
./health_check.sh

# Executar o playbook manualmente (do admin-control)
vagrant ssh admin-control -c "cd /home/vagrant && ansible-playbook -i inventory.ini playbook_lab.yml"
```

## 📂 Estrutura de Arquivos

```
project-root/
├── Vagrantfile                # Configuração Vagrant
├── playbook_lab.yml           # Playbook Ansible
├── inventory.ini              # Inventário Ansible
├── variables.yml              # Configurações customizáveis
├── health_check.sh            # Script de validação
└── README.md                  # Este arquivo
```

## 🔧 Troubleshooting

### Problema: Vagrant não encontra a box

**Solução**: Force o download manual
```bash
vagrant box add debian/bookworm64
vagrant box add bento/ubuntu-24.04
vagrant box add ubuntu/jammy64
```

### Problema: SSH falha ao conectar

**Solução**: Recrie as chaves SSH
```bash
vagrant destroy -f
vagrant up
```

### Problema: Playbook falha no primeiro boot

**Solução**: Execute manualmente
```bash
vagrant ssh admin-control
cd /home/vagrant
ansible-playbook -i inventory.ini playbook_lab.yml -v
```

### Problema: A VM do terminal gráfico é muito lenta

**Solução**: Aumentar memória em `variables.yml`
```yaml
vms:
  publico:
    memory: 4096  # Aumentar de 3072
```

## 📚 Próximos Passos

Após o laboratório estar pronto, você pode:

1. **Estudar RBAC**: Compare as permissões dos usuários `gestor_pro` vs `aluno`
2. **Praticar Ansible**: Modifique `playbook_lab.yml` para adicionar novas tasks
3. **Simular cenários**: Crie novos usuários, instale pacotes, configure serviços
4. **Documentar**: Use o terminal gráfico para tomar notas durante o aprendizado

## 🤝 Contribuições

Para melhorias, sugestões ou correções:
1. Abra uma issue descrevendo o problema/melhoria
2. Crie um pull request com suas mudanças
3. Mantenha a consistência com o estilo existente

## 📞 Suporte

Se encontrar problemas:
1. Verifique o arquivo `Vagrantfile` para erros de sintaxe
2. Execute `vagrant validate` para validar a configuração
3. Verifique logs: `vagrant up --debug`
4. Consulte a [documentação oficial do Vagrant](https://www.vagrantup.com/docs)

## 📄 Licença

Este projeto é fornecido como está para fins educacionais.

---

**Última atualização**: 2026-07-21  
**Versão**: 2.0 (Com Health Checks, Automação e Variáveis)
