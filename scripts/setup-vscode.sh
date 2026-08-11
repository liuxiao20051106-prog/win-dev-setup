#!/usr/bin/env bash
# VSCode 安装与配置模块
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/lib/utils.sh"

setup_vscode() {
    log_step "VSCode 安装与配置"

    # 1. 安装 VSCode
    if is_installed code Microsoft.VisualStudioCode; then
        log_ok "VSCode 已安装"
        if ! confirm "是否重新安装 VSCode？"; then
            log_info "跳过 VSCode 安装"
        fi
    else
        winget_install Microsoft.VisualStudioCode "Visual Studio Code" || {
            log_error "请手动安装 VSCode: https://code.visualstudio.com/"
            return 1
        }
    fi

    # 2. 安装扩展
    local ext_file="$ROOT_DIR/configs/vscode/extensions.txt"
    if [ -f "$ext_file" ]; then
        log_info "正在安装 VSCode 扩展..."
        local installed=0 skipped=0 failed=0
        while IFS= read -r ext; do
            # 跳过注释和空行
            [[ "$ext" =~ ^#.*$ ]] && continue
            [[ -z "$ext" ]] && continue
            if code --list-extensions 2>/dev/null | grep -qi "^${ext}$"; then
                ((skipped++))
                continue
            fi
            if code --install-extension "$ext" --force &>/dev/null; then
                ((installed++))
                log_ok "  $ext"
            else
                ((failed++))
                log_warn "  $ext (失败)"
            fi
        done < "$ext_file"
        log_info "扩展安装完成: $installed 新装, $skipped 已存在, $failed 失败"
    fi

    # 3. 写入 VSCode 设置
    local vscode_user="$HOME/AppData/Roaming/Code/User"
    if [ ! -d "$vscode_user" ]; then
        vscode_user="$(get_win_home)/AppData/Roaming/Code/User"
    fi
    if [ -d "$(dirname "$vscode_user")" ]; then
        safe_write "$ROOT_DIR/configs/vscode/settings.json" "$vscode_user/settings.json"
    else
        log_warn "未找到 VSCode 配置目录，跳过 settings.json"
        log_info "首次启动 VSCode 后再运行本脚本即可"
    fi

    log_ok "VSCode 配置完成"
    return 0
}

setup_vscode
