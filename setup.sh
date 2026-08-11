#!/usr/bin/env bash
# ============================================================
# Windows 开发环境一键配置 — 主安装器
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# ============================================================
# 模块注册表
# ============================================================
# 格式: "编号|名称|描述|脚本路径|默认选中"
MODULES=(
    "1|Git 配置|安装 Git + 用户信息 + 别名 + 编码优化|scripts/setup-git.sh|1"
    "2|Bash 美化|.bashrc/.bash_profile + 别名 + 提示符|scripts/setup-bash.sh|1"
    "3|Node.js 开发环境|nvm + Node LTS + npm 镜像 + 常用全局包|scripts/setup-node.sh|0"
    "4|Python 开发环境|Python + pip 镜像 + virtualenv + poetry|scripts/setup-python.sh|0"
    "5|VSCode 配置|VSCode 安装 + 扩展 + settings.json|scripts/setup-vscode.sh|0"
    "6|终端美化|Windows Terminal + Starship + Nerd Font|scripts/setup-terminal.sh|0"
    "7|SSH 密钥|SSH Key 生成 + config（含国内优化）|scripts/setup-ssh.sh|0"
    "8|Claude Code|AI 编程助手 + Skills 仓库 + 中文配置|scripts/setup-claude.sh|0"
    "9|常用开发工具|winget 批量安装（7zip/Postman/DBeaver 等）|scripts/setup-utils.sh|0"
)

# ============================================================
# 菜单渲染
# ============================================================

print_banner() {
    clear
    echo ""
    printf "${CYAN}${BOLD}┌──────────────────────────────────────────────┐${NC}\n"
    printf "${CYAN}${BOLD}│${NC}                                              ${CYAN}${BOLD}│${NC}\n"
    printf "${CYAN}${BOLD}│${NC}   ${BOLD}Windows 开发者环境一键配置${NC}                   ${CYAN}${BOLD}│${NC}\n"
    printf "${CYAN}${BOLD}│${NC}   ${GREEN}✦${NC} 国内镜像加速  ${GREEN}✦${NC} 交互式安装  ${GREEN}✦${NC} 模块化可选    ${CYAN}${BOLD}│${NC}\n"
    printf "${CYAN}${BOLD}│${NC}                                              ${CYAN}${BOLD}│${NC}\n"
    printf "${CYAN}${BOLD}└──────────────────────────────────────────────┘${NC}\n"
    echo ""
}

print_menu() {
    local selected=("$@")
    echo "请选择要安装的模块（输入编号，空格分隔，如 1 3 5）："
    echo ""
    for mod in "${MODULES[@]}"; do
        IFS='|' read -r id name desc script default <<< "$mod"
        local mark=" "
        if [[ " ${selected[*]} " == *" $id "* ]]; then
            mark="${GREEN}✔${NC}"
        fi
        printf "  ${CYAN}[${mark}${CYAN}]${NC} ${BOLD}%s.${NC} %-20s ${GREEN}%s${NC}\n" "$id" "$name" "$desc"
    done
    echo ""
    echo "  ${YELLOW}A${NC}  全选    ${YELLOW}S${NC}  开始安装    ${YELLOW}Q${NC}  退出"
    echo ""
}

# ============================================================
# 主循环
# ============================================================

main() {
    # 默认选中 1 和 2
    local selected=(1 2)

    while true; do
        print_banner
        print_menu "${selected[@]}"

        read -rp "> " input
        input=$(echo "$input" | tr '[:lower:]' '[:upper:]')

        case "$input" in
            Q)
                echo ""
                log_info "已退出"
                exit 0
                ;;
            A)
                selected=(1 2 3 4 5 6 7 8 9)
                log_info "已全选"
                sleep 0.5
                ;;
            S)
                if [ ${#selected[@]} -eq 0 ]; then
                    log_error "至少选择一个模块"
                    sleep 1
                    continue
                fi
                break
                ;;
            *)
                # 解析输入：空格分隔的编号
                local new_selected=()
                for part in $input; do
                    if [[ "$part" =~ ^[1-9]$ ]]; then
                        # 切换选中状态
                        local found=0
                        for s in "${selected[@]}"; do
                            if [ "$s" == "$part" ]; then
                                found=1
                                break
                            fi
                        done
                        if [ "$found" -eq 0 ]; then
                            selected+=("$part")
                        else
                            # 取消选中
                            local tmp=()
                            for s in "${selected[@]}"; do
                                [ "$s" != "$part" ] && tmp+=("$s")
                            done
                            selected=("${tmp[@]}")
                        fi
                    fi
                done
                # 排序
                selected=($(printf '%s\n' "${selected[@]}" | sort -n))
                ;;
        esac
    done

    # ============================================================
    # 执行安装
    # ============================================================
    print_banner
    printf "${BOLD}即将安装以下模块：${NC}\n\n"
    local sorted=($(printf '%s\n' "${selected[@]}" | sort -n))
    for id in "${sorted[@]}"; do
        for mod in "${MODULES[@]}"; do
            IFS='|' read -r mid name desc script default <<< "$mod"
            if [ "$mid" == "$id" ]; then
                printf "  ${GREEN}▸${NC} %s — %s\n" "$name" "$desc"
            fi
        done
    done
    echo ""
    if ! confirm "确认开始安装？"; then
        log_info "已取消"
        exit 0
    fi

    # 按顺序执行模块
    echo ""
    echo "========================================"
    printf "${BOLD}  开始安装${NC}\n"
    echo "========================================"
    echo ""

    for id in "${sorted[@]}"; do
        for mod in "${MODULES[@]}"; do
            IFS='|' read -r mid name desc script default <<< "$mod"
            if [ "$mid" == "$id" ]; then
                local script_path="$SCRIPT_DIR/$script"
                if [ -f "$script_path" ]; then
                    if bash "$script_path"; then
                        report_status 0 "$name"
                    else
                        report_status 1 "$name"
                    fi
                else
                    log_error "脚本不存在: $script_path"
                    report_status 1 "$name"
                fi
            fi
        done
    done

    # 打印结果摘要
    print_summary

    log_info "配置完成！建议重启终端以应用所有更改。"
    echo ""
}

main
