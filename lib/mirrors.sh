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
    # 仅加速 github.com，不影响其他仓库
    if confirm "是否配置 GitHub SSH 加速（通过镜像）？"; then
        git config --global url."git@git.zhlh6.cn:".insteadOf "https://github.com/"
        log_ok "GitHub 镜像加速已配置"
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
