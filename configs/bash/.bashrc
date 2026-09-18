# ============================================================
# Bash RC — Windows 开发者优化配置
# 安装来源: win-dev-setup
# ============================================================

# --- 历史记录 ---
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend
# 不记录以空格开头的命令
export HISTIGNORE="[ \t]*"

# --- 终端颜色 ---
export CLICOLOR=1
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# --- 编辑器 ---
if command -v code &>/dev/null; then
    export EDITOR="code --wait"
else
    export EDITOR="vi"
fi
export VISUAL="$EDITOR"
export GIT_EDITOR="$EDITOR"

# --- 语言与编码 ---
export LANG=zh_CN.UTF-8
export LC_ALL=zh_CN.UTF-8

# --- 路径（用户级 bin 目录） ---
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# ============================================================
# 别名
# ============================================================
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'

# Git 快捷别名
alias gs='git status'
alias gp='git pull'
alias gph='git push'
alias gc='git commit'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --all -20'
alias glg='git log --graph --pretty=format:"%C(yellow)%h%Creset %C(green)%an%Creset %s %C(blue)%cr%Creset" -20'
alias gst='git stash'
alias gstp='git stash pop'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias gcp='git cherry-pick'

# 常用
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias md='mkdir -p'
alias path='echo "$PATH" | tr ":" "\n"'
alias ip='curl -s ip.sb && echo'

# ============================================================
# 函数
# ============================================================
# 创建目录并进入
mkcd() { mkdir -p "$1" && cd "$1" || return 1; }

# 解压任意格式
extract() {
    if [ -f "$1" ]; then
        case $1 in
            *.tar.bz2) tar xjf "$1"   ;;
            *.tar.gz)  tar xzf "$1"   ;;
            *.bz2)     bunzip2 "$1"   ;;
            *.rar)     unrar x "$1"   ;;
            *.gz)      gunzip "$1"    ;;
            *.tar)     tar xf "$1"    ;;
            *.tbz2)    tar xjf "$1"   ;;
            *.tgz)     tar xzf "$1"   ;;
            *.zip)     unzip "$1"     ;;
            *.7z)      7z x "$1"      ;;
            *)         echo "未知格式: $1" ;;
        esac
    else
        echo "'$1' 不是有效文件"
    fi
}

# 快速搜索历史
hs() { history | grep -i "$1"; }

# ============================================================
# Starship 提示符（如果已安装）
# ============================================================
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi
