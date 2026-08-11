#!/usr/bin/env bash
# SSH 密钥生成模块
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/lib/utils.sh"

setup_ssh() {
    log_step "SSH 密钥配置"

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    # 1. 生成 SSH Key
    local key_type="ed25519"
    local key_path="$HOME/.ssh/id_${key_type}"

    if [ -f "$key_path" ]; then
        log_info "SSH 密钥已存在: $key_path"
        if ! confirm "是否生成新密钥（覆盖旧密钥）？"; then
            log_info "跳过密钥生成"
        else
            backup_file "$key_path"
            backup_file "${key_path}.pub"
            local email=""
            email=$(git config --global user.email 2>/dev/null || echo "")
            [ -z "$email" ] && email=$(required_input "请输入你的邮箱（用于 SSH 注释）")
            ssh-keygen -t "$key_type" -C "$email" -f "$key_path" -N "" && \
                log_ok "SSH 密钥已生成" || log_error "密钥生成失败"
        fi
    else
        local email=""
        email=$(git config --global user.email 2>/dev/null || echo "")
        [ -z "$email" ] && email=$(required_input "请输入你的邮箱（用于 SSH 注释）")
        ssh-keygen -t "$key_type" -C "$email" -f "$key_path" -N "" && \
            log_ok "SSH 密钥已生成" || log_error "密钥生成失败"
    fi

    # 2. 写入 SSH config
    if [ ! -f "$HOME/.ssh/config" ]; then
        cat > "$HOME/.ssh/config" <<'EOF'
# SSH Config — 安装来源: win-dev-setup

# GitHub（国内优化：使用镜像或代理加速）
Host github.com
    HostName github.com
    User git
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_ed25519
    # 如果 GitHub 连接慢，取消下面注释：
    # HostName ssh.github.com
    # Port 443

# GitLab 国内镜像
Host gitlab.com
    HostName gitlab.com
    User git
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_ed25519

# Gitee（码云）
Host gitee.com
    HostName gitee.com
    User git
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_ed25519

# 通用配置
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 10
    TCPKeepAlive yes
EOF
        chmod 600 "$HOME/.ssh/config"
        log_ok "SSH config 已创建"
    else
        log_info "SSH config 已存在，跳过"
    fi

    # 3. 显示公钥
    if [ -f "${key_path}.pub" ]; then
        echo ""
        printf "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        printf "${BOLD}你的 SSH 公钥（添加到 GitHub/GitLab/Gitee）：${NC}\n\n"
        cat "${key_path}.pub"
        printf "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
        echo ""
        log_info "GitHub:  https://github.com/settings/keys"
        log_info "GitLab:  https://gitlab.com/-/profile/keys"
        log_info "Gitee:   https://gitee.com/profile/sshkeys"
    fi

    log_ok "SSH 配置完成"
    return 0
}

setup_ssh
