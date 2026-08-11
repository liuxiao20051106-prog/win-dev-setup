#!/usr/bin/env bash
# 常用开发工具批量安装模块
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
source "$ROOT_DIR/lib/utils.sh"

# 工具清单：ID 名称 分类
TOOLS=(
    # 压缩解压
    "7zip.7zip|7-Zip|压缩解压"
    # 文件搜索
    "voidtools.Everything|Everything|文件搜索"
    # 终端
    "Microsoft.WindowsTerminal|Windows Terminal|终端"
    # API 调试
    "Postman.Postman|Postman|API 调试"
    # 数据库
    "DBeaver.DBeaver|DBeaver|数据库管理"
    # 编辑器
    "Notepad++.Notepad++|Notepad++|文本编辑器"
    # 效率
    "JanDeDobbeleer.OhMyPosh|Oh My Posh|终端美化"
    "Alacritty.Alacritty|Alacritty|GPU 终端"
    # 网络
    "Cloudflare.cloudflared|cloudflared|Cloudflare Tunnel"
    # 容器
    "Docker.DockerDesktop|Docker Desktop|容器"
    # API 客户端
    "Insomnia.Insomnia|Insomnia|REST 客户端"
    # 十六进制编辑器
    "REALiX.HxD|HxD|Hex 编辑器"
    # 截图
    "ShareX.ShareX|ShareX|截图工具"
    # 剪贴板
    "Ditto.Ditto|Ditto|剪贴板管理"
)

setup_utils() {
    log_step "常用开发工具安装"

    echo "以下工具可用（通过 winget 安装）："
    echo ""
    local i=1
    for tool in "${TOOLS[@]}"; do
        IFS='|' read -r id name cat <<< "$tool"
        local status=""
        if is_installed "${name,,}" "$id" 2>/dev/null; then
            status="${GREEN}已安装${NC}"
        fi
        printf "  %2d. %-25s %-15s %s\n" "$i" "$name" "[$cat]" "$status"
        ((i++))
    done

    echo ""
    echo "输入编号选择安装（如 1 3 5-7，回车跳过）："
    read -rp "> " selection

    if [ -z "$selection" ]; then
        log_info "跳过工具安装"
        return 0
    fi

    # 解析选择
    local selected=()
    for part in $selection; do
        if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            for s in $(seq "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"); do
                selected+=("$s")
            done
        elif [[ "$part" =~ ^[0-9]+$ ]]; then
            selected+=("$part")
        fi
    done

    # 安装
    for idx in "${selected[@]}"; do
        [ "$idx" -lt 1 ] && continue
        [ "$idx" -gt "${#TOOLS[@]}" ] && continue
        local tool="${TOOLS[$((idx-1))]}"
        IFS='|' read -r id name cat <<< "$tool"
        winget_install "$id" "$name" || true
    done

    log_ok "工具安装完成"
    return 0
}

setup_utils
