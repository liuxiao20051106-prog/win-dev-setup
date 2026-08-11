#!/usr/bin/env bash
# Claude Code 安装模块（可选）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/lib/utils.sh"
source "$ROOT_DIR/lib/mirrors.sh"

CLAUDE_SKILLS_REPO="https://github.com/grapeyolo/claude-skills.git"

setup_claude() {
    log_step "Claude Code 安装与配置"

    # 1. 检查 Node.js
    if ! is_installed node; then
        log_error "Node.js 未安装，请先运行 Node.js 模块（选项 3）"
        return 1
    fi

    # 2. 安装 Claude Code CLI
    if is_installed claude; then
        log_ok "Claude Code 已安装 ($(claude --version 2>/dev/null | head -1))"
        if confirm "是否更新 Claude Code？"; then
            npm install -g @anthropic-ai/claude-code@latest
            log_ok "Claude Code 已更新"
        fi
    else
        log_info "正在安装 Claude Code..."
        npm install -g @anthropic-ai/claude-code && \
            log_ok "Claude Code 安装完成" || {
            log_error "Claude Code 安装失败"
            return 1
        }
    fi

    # 3. 克隆 Claude Skills 仓库
    local skills_dir="$HOME/claude-skills"
    if [ -d "$skills_dir/.git" ]; then
        log_info "Claude Skills 仓库已存在于 $skills_dir"
        if confirm "是否 git pull 更新？"; then
            git -C "$skills_dir" pull --rebase && log_ok "Skills 已更新" || log_warn "更新失败"
        fi
    else
        log_info "正在克隆 Claude Skills 仓库..."
        if git clone "$CLAUDE_SKILLS_REPO" "$skills_dir" 2>/dev/null; then
            log_ok "Skills 仓库已克隆到 $skills_dir"
        else
            log_warn "克隆失败，请手动克隆："
            log_info "  git clone $CLAUDE_SKILLS_REPO ~/claude-skills"
        fi
    fi

    # 4. Claude Code 中文配置
    log_info "配置 Claude Code 中文优化..."
    mkdir -p "$HOME/.claude"
    if [ ! -f "$HOME/.claude/settings.json" ]; then
        cat > "$HOME/.claude/settings.json" <<'EOF'
{
    "model": "claude-sonnet-5",
    "outputStyle": "zh-cn"
}
EOF
        log_ok "Claude Code 中文配置完成"
    else
        log_info "~/.claude/settings.json 已存在，跳过"
    fi

    log_ok "Claude Code 配置完成"
    log_info "运行 'claude' 启动 Claude Code"
    return 0
}

setup_claude
