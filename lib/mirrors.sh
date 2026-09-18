#!/usr/bin/env bash
# 国内镜像源配置
set -euo pipefail

# ============================================================
# npm 镜像
# ============================================================
NPM_MIRROR="https://registry.npmmirror.com"

setup_npm_mirror() {
    if command_exists npm; then
        npm config set registry "$NPM_MIRROR"
        log_ok "npm 镜像已设置为: $NPM_MIRROR"
    else
        log_warn "npm 未安装，跳过镜像配置"
        return 1
    fi
}

# ============================================================
# pip 镜像
# ============================================================
PIP_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple"

setup_pip_mirror() {
    if command_exists pip; then
        pip config set global.index-url "$PIP_MIRROR"
        log_ok "pip 镜像已设置为: $PIP_MIRROR"
    elif command_exists pip3; then
        pip3 config set global.index-url "$PIP_MIRROR"
        log_ok "pip3 镜像已设置为: $PIP_MIRROR"
    else
        log_warn "pip 未安装，跳过镜像配置"
        return 1
    fi
}

# ============================================================
# Go 镜像
# ============================================================
setup_go_mirror() {
    if command_exists go; then
        go env -w GOPROXY=https://goproxy.cn,direct
        go env -w GO111MODULE=on
        log_ok "Go 代理已设置: https://goproxy.cn"
    else
        log_warn "Go 未安装，跳过镜像配置"
        return 1
    fi
}

# ============================================================
# Git 代理（GitHub 加速）
# ============================================================
setup_git_proxy() {
    # GitHub 国内加速（通过 HTTPS 镜像）
    # ⚠️ 注意：使用第三方镜像存在安全风险，仅供网络受限时使用
    log_warn "GitHub 镜像加速会将所有 GitHub HTTPS 请求转发到第三方服务器"
    log_warn "存在中间人攻击和供应链安全风险，仅建议网络受限时使用"
    if confirm "是否配置 GitHub HTTPS 镜像加速？（不推荐在生产环境使用）"; then
        # 使用 HTTPS 镜像而非 SSH，降低配置门槛
        git config --global url."https://git.zhlh6.cn/".insteadOf "https://github.com/"
        log_ok "GitHub HTTPS 镜像加速已配置"
        log_info "如需撤销，运行: git config --global --unset url.https://git.zhlh6.cn/.insteadOf"
    else
        log_info "跳过 GitHub 加速"
    fi
}

# ============================================================
# cargo (Rust) 镜像
# ============================================================
setup_cargo_mirror() {
    if command_exists cargo; then
        mkdir -p ~/.cargo
        # 先备份已有配置
        backup_file "$HOME/.cargo/config.toml"
        cat > ~/.cargo/config.toml <<'EOF'
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
EOF
        log_ok "Cargo 镜像已设置为 USTC"
    fi
}

# ============================================================
# gem (Ruby) 镜像
# ============================================================
setup_gem_mirror() {
    if command_exists gem; then
        gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/ 2>/dev/null || true
        log_ok "Gem 镜像已设置为 ruby-china.com"
    fi
}
