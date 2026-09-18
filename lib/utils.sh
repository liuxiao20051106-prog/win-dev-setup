#!/usr/bin/env bash
# win-dev-setup 公共函数库
set -euo pipefail

# ============================================================
# 颜色定义
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ============================================================
# 日志函数
# ============================================================
log_info()  { printf "${BLUE}[INFO]${NC}  %s\n" "$*"; }
log_ok()    { printf "${GREEN}[OK]${NC}    %s\n" "$*"; }
log_warn()  { printf "${YELLOW}[WARN]${NC}  %s\n" "$*"; }
log_error() { printf "${RED}[ERROR]${NC} %s\n" "$*"; }
log_step()  { printf "\n${CYAN}${BOLD}▶ %s${NC}\n\n" "$*"; }

# ============================================================
# 工具检测
# ============================================================
command_exists() { command -v "$1" &>/dev/null; }

is_windows() {
    uname -s 2>/dev/null | grep -qi "mingw\|msys\|cygwin" && return 0
    return 1
}

# 获取 Windows 用户名（用于路径拼接）
get_win_home() {
    if [ -n "${USERPROFILE:-}" ]; then
        echo "$USERPROFILE"
    elif [ -n "${HOMEDRIVE:-}" ] && [ -n "${HOMEPATH:-}" ]; then
        echo "${HOMEDRIVE}${HOMEPATH}"
    else
        echo "$HOME"
    fi
}

# 转换 Unix 路径为 Windows 路径（用于 VSCode 等 Windows 原生工具）
unix_to_win() {
    local path="$1"
    if command_exists cygpath; then
        cygpath -w "$path"
    else
        log_warn "cygpath 不可用，路径转换可能不准确（建议安装 Git Bash 自带 cygpath）"
        echo "$path" | sed 's|^/\([a-zA-Z]\)/|\1:/|; s|/|\\|g'
    fi
}

# 转换 Windows 路径为 Unix 路径
win_to_unix() {
    local path="$1"
    if command_exists cygpath; then
        cygpath -u "$path"
    else
        echo "$path" | sed 's|\\|/|g; s|^\([a-zA-Z]\):|/\1|'
    fi
}

# ============================================================
# 备份与文件操作
# ============================================================
# 备份文件（如果存在）
backup_file() {
    local target="$1"
    if [ -f "$target" ] || [ -d "$target" ]; then
        local bak="${target}.bak.$(date +%Y%m%d_%H%M%S)"
        cp -r "$target" "$bak"
        log_warn "已备份: $target → $(basename "$bak")"
    fi
}

# 安全写入文件（先备份）
safe_write() {
    local src="$1"
    local dest="$2"
    backup_file "$dest"
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    log_ok "已写入: $dest"
}

# 创建符号链接（Windows 下用 cp 替代）
safe_link() {
    local src="$1"
    local dest="$2"
    backup_file "$dest"
    mkdir -p "$(dirname "$dest")"
    if is_windows; then
        # Git Bash 下 ln -s 不可靠，直接复制
        cp "$src" "$dest"
        log_ok "已复制: $dest → $src"
    else
        ln -sf "$src" "$dest"
        log_ok "已链接: $dest → $src"
    fi
}

# ============================================================
# 用户交互
# ============================================================
confirm() {
    local prompt="${1:-是否继续？}"
    read -rp "$prompt [y/N] " reply
    case "$reply" in
        [Yy]*) return 0 ;;
        *)     return 1 ;;
    esac
}

# 必填输入（不能为空）
required_input() {
    local prompt="$1"
    local value=""
    while [ -z "$value" ]; do
        read -rp "$prompt: " value
        if [ -z "$value" ]; then
            log_error "此项为必填，请输入"
        fi
    done
    echo "$value"
}

# 带默认值的输入
input_with_default() {
    local prompt="$1"
    local default="$2"
    local value=""
    read -rp "${prompt} [${default}]: " value
    echo "${value:-$default}"
}

# ============================================================
# 安装器工具
# ============================================================
# winget 安装（非交互模式）
winget_install() {
    local pkg_id="$1"
    local pkg_name="${2:-$pkg_id}"
    if command_exists winget; then
        log_info "winget 安装 $pkg_name ..."
        local tmp_log
        tmp_log=$(mktemp)
        winget install --id "$pkg_id" --silent --accept-package-agreements --accept-source-agreements 2>"$tmp_log" && {
            log_ok "$pkg_name 安装完成"
            rm -f "$tmp_log"
            return 0
        } || {
            log_warn "$pkg_name winget 安装失败，请手动安装"
            if [ -s "$tmp_log" ]; then
                log_info "错误详情: $(cat "$tmp_log" | head -3)"
            fi
            rm -f "$tmp_log"
            return 1
        }
    else
        log_warn "winget 不可用，跳过 $pkg_name 安装"
        return 1
    fi
}

# 检查是否已安装（优先用 winget list，其次 which）
is_installed() {
    local cmd="$1"
    local winget_id="${2:-}"
    if command_exists "$cmd"; then
        return 0
    fi
    if [ -n "$winget_id" ] && command_exists winget; then
        winget list --id "$winget_id" &>/dev/null && return 0
    fi
    return 1
}

# 报告结果
report_status() {
    local success="$1"
    local module_name="$2"
    if [ "$success" -eq 0 ]; then
        log_ok "$module_name — 完成"
        RESULTS_PASS+=("$module_name")
    else
        log_error "$module_name — 失败"
        RESULTS_FAIL+=("$module_name")
    fi
}

# ============================================================
# 结果汇总
# ============================================================
RESULTS_PASS=()
RESULTS_FAIL=()

print_summary() {
    echo ""
    echo "========================================"
    printf "${BOLD}  安装结果摘要${NC}\n"
    echo "========================================"
    if [ ${#RESULTS_PASS[@]} -gt 0 ]; then
        printf "${GREEN}  通过 (%d):${NC}\n" "${#RESULTS_PASS[@]}"
        for m in "${RESULTS_PASS[@]}"; do
            printf "    ✓ %s\n" "$m"
        done
    fi
    if [ ${#RESULTS_FAIL[@]} -gt 0 ]; then
        printf "${RED}  失败 (%d):${NC}\n" "${#RESULTS_FAIL[@]}"
        for m in "${RESULTS_FAIL[@]}"; do
            printf "    ✗ %s\n" "$m"
        done
    fi
    echo "========================================"
    echo ""
}
