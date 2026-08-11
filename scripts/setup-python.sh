#!/usr/bin/env bash
# Python 开发环境模块
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/lib/utils.sh"
source "$ROOT_DIR/lib/mirrors.sh"

setup_python() {
    log_step "Python 开发环境"

    # 1. 安装 Python
    if is_installed python3 Python.Python.3.12; then
        log_ok "Python 已安装 ($(python3 --version 2>/dev/null || python --version 2>/dev/null))"
        if ! confirm "是否重新安装/更新 Python？"; then
            log_info "跳过 Python 安装"
        fi
    else
        winget_install Python.Python.3.12 "Python 3.12" || {
            log_error "请手动安装 Python: https://www.python.org/"
            return 1
        }
    fi

    # 2. 配置 pip 镜像
    setup_pip_mirror

    # 3. 安装/升级常用工具
    log_info "安装 Python 常用工具..."
    local pkgs=(pip setuptools wheel virtualenv poetry pipenv)
    for pkg in "${pkgs[@]}"; do
        if pip show "$pkg" &>/dev/null; then
            pip install --upgrade "$pkg" -q 2>/dev/null && log_info "  $pkg 已更新" || true
        else
            pip install "$pkg" -q 2>/dev/null && log_ok "  $pkg 安装完成" || log_warn "  $pkg 安装失败"
        fi
    done

    log_ok "Python 环境配置完成"
    return 0
}

setup_python
