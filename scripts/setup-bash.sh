#!/usr/bin/env bash
# Bash Shell 美化模块
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/lib/utils.sh"

setup_bash() {
    log_step "Bash Shell 美化"

    # 部署 .bashrc
    safe_write "$ROOT_DIR/configs/bash/.bashrc" "$HOME/.bashrc"

    # 部署 .bash_profile
    safe_write "$ROOT_DIR/configs/bash/.bash_profile" "$HOME/.bash_profile"

    # 创建本地覆盖文件（如果不存在）
    if [ ! -f "$HOME/.bashrc.local" ]; then
        cat > "$HOME/.bashrc.local" <<'EOF'
# 本地自定义配置（机子特定，不会被 win-dev-setup 覆盖）

# 示例：
# export JAVA_HOME="/c/Program Files/Java/jdk-17"
# alias myproject="cd ~/projects/myproject"
EOF
        log_ok "已创建 ~/.bashrc.local（本地自定义配置）"
    else
        log_info "~/.bashrc.local 已存在，跳过"
    fi

    log_ok "Bash 配置完成"
    log_info "重新打开终端或执行 'source ~/.bashrc' 使配置生效"
    return 0
}

setup_bash
