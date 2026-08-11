#!/usr/bin/env bash
# Node.js 开发环境模块
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/lib/utils.sh"
source "$ROOT_DIR/lib/mirrors.sh"

setup_node() {
    log_step "Node.js 开发环境"

    # 1. 检查 Node 是否已安装
    if is_installed node OpenJS.NodeJS.LTS; then
        log_ok "Node.js 已安装 ($(node -v 2>/dev/null || echo '未知版本'))"
        if ! confirm "是否重新安装/更新 Node.js？"; then
            log_info "跳过 Node.js 安装"
        else
            winget_install OpenJS.NodeJS.LTS "Node.js LTS"
        fi
    else
        winget_install OpenJS.NodeJS.LTS "Node.js LTS" || {
            log_error "请手动安装 Node.js: https://nodejs.org/"
            return 1
        }
    fi

    # 2. 配置 npm 镜像
    setup_npm_mirror

    # 3. 安装常用全局包
    log_info "安装常用 npm 全局包..."
    local pkgs=(pnpm yarn typescript tsx nodemon http-server)
    for pkg in "${pkgs[@]}"; do
        if npm list -g --depth=0 2>/dev/null | grep -q "$pkg"; then
            log_info "  $pkg 已安装，跳过"
        else
            npm install -g "$pkg" && log_ok "  $pkg 安装完成" || log_warn "  $pkg 安装失败"
        fi
    done

    log_ok "Node.js 环境配置完成"
    return 0
}

setup_node
