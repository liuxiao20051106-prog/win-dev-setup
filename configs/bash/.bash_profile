# ============================================================
# Bash Profile — 登录 Shell 配置
# ============================================================

# 加载 bashrc
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi

# 加载本地覆盖（机子特定配置，不提交到版本控制）
if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi
