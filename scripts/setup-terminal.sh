#!/usr/bin/env bash
# 终端美化模块 — Windows Terminal + Starship + Nerd Font
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/lib/utils.sh"

setup_terminal() {
    log_step "终端美化"

    # 1. Windows Terminal
    if is_installed wt Microsoft.WindowsTerminal; then
        log_ok "Windows Terminal 已安装"
    else
        log_info "正在安装 Windows Terminal..."
        winget_install Microsoft.WindowsTerminal "Windows Terminal" || {
            log_warn "Windows Terminal 安装失败，请从 Microsoft Store 手动安装"
        }
    fi

    # 2. Starship 提示符
    if is_installed starship Starship.Starship; then
        log_ok "Starship 已安装 ($(starship --version 2>/dev/null | head -1))"
    else
        log_info "正在安装 Starship..."
        if is_installed winget; then
            winget_install Starship.Starship "Starship" || {
                # 备选：curl 安装
                log_info "尝试 curl 安装 Starship..."
                curl -sS https://starship.rs/install.sh | sh -s -- -y 2>/dev/null && \
                    log_ok "Starship 安装完成" || log_warn "Starship 安装失败"
            }
        else
            curl -sS https://starship.rs/install.sh | sh -s -- -y 2>/dev/null && \
                log_ok "Starship 安装完成" || log_warn "Starship 安装失败"
        fi
    fi

    # 3. Nerd Font (Caskaydia Cove)
    log_info "Nerd Font 下载..."
    local font_name="CaskaydiaCoveNerdFont"
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/${font_name}.zip"
    local font_dest="$HOME/Downloads/${font_name}"

    if [ -d "$font_dest" ]; then
        log_info "Nerd Font 已下载到 $font_dest"
    else
        mkdir -p "$font_dest"
        if curl -sSL "$font_url" -o "$font_dest/fonts.zip" 2>/dev/null; then
            unzip -qo "$font_dest/fonts.zip" -d "$font_dest" 2>/dev/null || true
            rm -f "$font_dest/fonts.zip"
            log_ok "字体下载完成: $font_dest"
            echo ""
            log_warn "请手动安装字体：打开 $font_dest，全选 .ttf 文件 → 右键 → 安装"
            log_info "然后在终端设置中把字体设为 '$font_name Mono'"
        else
            log_warn "字体下载失败，请手动下载: $font_url"
        fi
    fi

    # 4. Starship 配置
    safe_write "$ROOT_DIR/configs/terminal/starship.toml" "$HOME/.config/starship.toml"

    log_ok "终端美化完成"
    return 0
}

setup_terminal
