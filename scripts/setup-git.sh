#!/usr/bin/env bash
# Git 安装与配置模块
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/lib/utils.sh"

setup_git() {
    log_step "Git 安装与配置"

    # 1. 安装 Git
    if is_installed git Git.Git; then
        log_ok "Git 已安装 ($(git --version | head -1))"
    else
        log_info "正在安装 Git..."
        winget_install Git.Git "Git" || {
            log_error "请手动安装 Git: https://git-scm.com/download/win"
            return 1
        }
        log_warn "Git 安装后请重启终端以生效"
    fi

    # 2. 配置用户信息
    echo ""
    log_info "配置 Git 用户信息"

    local current_name current_email
    current_name=$(git config --global user.name 2>/dev/null || echo "")
    current_email=$(git config --global user.email 2>/dev/null || echo "")

    if [ -n "$current_name" ] && [ -n "$current_email" ]; then
        echo "当前配置:"
        echo "  用户名: $current_name"
        echo "  邮箱:   $current_email"
        if confirm "是否更新用户信息？"; then
            current_name=""
        fi
    fi

    if [ -z "$current_name" ]; then
        git config --global user.name "$(required_input '请输入你的名字（如 Zhang San）')"
    fi
    if [ -z "$current_email" ]; then
        git config --global user.email "$(required_input '请输入你的邮箱')"
    fi

    # 3. 写入配置文件
    log_info "写入 Git 配置..."
    safe_write "$ROOT_DIR/configs/git/.gitconfig" "$HOME/.gitconfig"

    log_ok "Git 配置完成"
    return 0
}

setup_git
