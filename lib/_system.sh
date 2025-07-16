#!/bin/bash

#######################################
# creates user - VERSION CORRIGIDA
# Arguments:
#   None
#######################################
system_create_user() {
  print_banner
  printf "${WHITE} 💻 Agora, vamos criar o usuário para a instancia...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Verificar se a variável está definida
  if [[ -z "$mysql_root_password" ]]; then
    printf "${RED} ❌ Erro: Senha não definida. Verifique a variável mysql_root_password${NC}"
    exit 1
  fi

  sudo su - root <<EOF
  # Verificar se o usuário já existe
  if id "deploy" &>/dev/null; then
    echo "Usuario deploy ja existe. Removendo..."
    userdel -r deploy 2>/dev/null || true
  fi

  # Criar o usuário usando diferentes métodos de criptografia
  if command -v mkpasswd &> /dev/null; then
    # Usar mkpasswd se disponível (mais confiável)
    useradd -m -p \$(mkpasswd -m sha-512 "${mysql_root_password}") -s /bin/bash -G sudo deploy
  else
    # Fallback para openssl com método mais compatível
    useradd -m -p \$(openssl passwd -1 "${mysql_root_password}") -s /bin/bash -G sudo deploy
  fi

  # Adicionar ao grupo sudo
  usermod -aG sudo deploy
  
  # Criar diretório home se não existir
  mkdir -p /home/deploy
  chown deploy:deploy /home/deploy
  
  # Definir permissões corretas
  chmod 755 /home/deploy
  
  # Verificar se o usuário foi criado corretamente
  if id "deploy" &>/dev/null; then
    echo "Usuario deploy criado com sucesso!"
  else
    echo "Erro ao criar usuario deploy!"
    exit 1
  fi
EOF

  sleep 2
}

#######################################
# Alternative method - Criar usuário sem senha criptografada
# Arguments:
#   None
#######################################
system_create_user_alternative() {
  print_banner
  printf "${WHITE} 💻 Criando usuário deploy (método alternativo)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  sudo su - root <<EOF
  # Verificar se o usuário já existe
  if id "deploy" &>/dev/null; then
    echo "Usuario deploy ja existe. Removendo..."
    userdel -r deploy 2>/dev/null || true
  fi

  # Criar usuário sem senha inicialmente
  useradd -m -s /bin/bash -G sudo deploy
  
  # Definir a senha usando echo e chpasswd
  echo "deploy:${mysql_root_password}" | chpasswd
  
  # Criar diretório home se não existir
  mkdir -p /home/deploy
  chown deploy:deploy /home/deploy
  chmod 755 /home/deploy
  
  # Verificar se o usuário foi criado corretamente
  if id "deploy" &>/dev/null; then
    echo "Usuario deploy criado com sucesso!"
  else
    echo "Erro ao criar usuario deploy!"
    exit 1
  fi
EOF

  sleep 2
}

#######################################
# Debug function - Verificar variáveis
# Arguments:
#   None
#######################################
debug_variables() {
  print_banner
  printf "${WHITE} 💻 Verificando variáveis...${GRAY_LIGHT}"
  printf "\n\n"

  echo "mysql_root_password definida: $([[ -n "$mysql_root_password" ]] && echo "SIM" || echo "NÃO")"
  echo "Tamanho da senha: ${#mysql_root_password}"
  
  if [[ -n "$mysql_root_password" ]]; then
    echo "Primeiros 3 caracteres: ${mysql_root_password:0:3}..."
  fi
}
