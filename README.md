# 🚀 Windows 开发者环境一键配置

面向国内 Windows 开发者的交互式环境配置工具。新机器到手、重装系统后，一个命令即可完成全套开发环境搭建。

## 特性

- 🖱 **交互式菜单** — 勾选需要的模块，灵活可控，不用全装
- 🇨🇳 **国内优化** — 内置 npm/pip/go 等国内镜像，告别网络问题
- 📦 **模块化** — Git / Bash / Node / Python / VSCode / 终端 / SSH / Claude Code 独立可选
- 🔒 **安全备份** — 覆盖前自动备份已有配置，不怕丢设置
- ♻️ **幂等安装** — 可重复运行，检测已安装自动跳过
- 🪶 **轻量依赖** — 只需 winget（Win10+ 自带）和 Git Bash，其他按需安装

## 快速开始

### 方式一：本地运行（推荐）

```powershell
# 克隆仓库
git clone https://github.com/<your-username>/win-dev-setup.git
cd win-dev-setup

# PowerShell 中运行
.\setup.ps1
```

### 方式二：一键远程运行

```powershell
# 在 PowerShell（管理员）中粘贴执行
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
iwr https://raw.gitmirror.com/<your-username>/win-dev-setup/main/setup.ps1 | iex
```

> 💡 `raw.gitmirror.com` 是 GitHub 国内加速镜像，首次使用建议先克隆到本地。

### 前置条件

| 条件 | 说明 |
|------|------|
| Windows 10 22H2+ / Windows 11 | winget 已内置 |
| 网络畅通 | 下载工具需要联网 |
| 管理员权限（推荐） | 部分工具安装需要 |

## 模块一览

运行后会出现交互菜单，输入编号勾选/取消，按 `S` 开始安装：

```
┌──────────────────────────────────────────────┐
│   Windows 开发者环境一键配置                    │
│   ✦ 国内镜像加速  ✦ 交互式安装  ✦ 模块化可选    │
└──────────────────────────────────────────────┘

 [✔] 1. Git 配置             安装 Git + 用户信息 + 别名 + 编码
 [✔] 2. Bash 美化            .bashrc + 别名 + 提示符 + 历史
 [ ] 3. Node.js 开发环境      nvm + Node LTS + npm 镜像 + 全局包
 [ ] 4. Python 开发环境       Python 3.12 + pip 镜像 + poetry
 [ ] 5. VSCode 配置          扩展批量安装 + settings.json
 [ ] 6. 终端美化             Windows Terminal + Starship + 字体
 [ ] 7. SSH 密钥             SSH Key + config（含国内优化）
 [ ] 8. Claude Code          AI 编程助手 + Skills + 中文配置
 [ ] 9. 常用开发工具          winget 批量安装 7zip/DBeaver 等

 A 全选   S 开始安装   Q 退出
```

### 各模块详情

**Git 配置**
- winget 安装 Git
- 交互式输入用户名和邮箱
- 配置：UTF-8 编码、LF 换行、rebase pull、实用别名（lg/undo/amend 等）

**Bash 美化**
- 部署 `.bashrc` / `.bash_profile`
- 配置：10000 条历史、颜色输出、Git 快捷别名（gs/gp/gco/gl 等）
- 创建 `.bashrc.local` 用于本地自定义（不会被覆盖）

**Node.js 开发环境**
- winget 安装 Node.js LTS
- npm 镜像设为 `npmmirror.com`
- 安装：pnpm、yarn、typescript、tsx、nodemon

**Python 开发环境**
- winget 安装 Python 3.12
- pip 镜像设为清华源
- 安装/升级：virtualenv、poetry、pipenv

**VSCode 配置**
- winget 安装 VSCode
- 批量安装推荐扩展（GitLens、Prettier、Python、Go 等）
- 写入优化后的 settings.json（字体、自动保存、终端等）

**终端美化**
- winget 安装 Windows Terminal
- 安装 Starship 提示符 + 主题配置
- 下载 Nerd Font（CaskaydiaCove），手动安装

**SSH 密钥**
- 生成 ed25519 密钥（更安全更快）
- 写入 SSH config：GitHub/GitLab/Gitee + 心跳保活
- 自动显示公钥，方便添加到各平台

**Claude Code（可选）**
- npm 安装 Claude Code CLI
- 克隆 Claude Skills 仓库（code-review、git-workflow 等）
- 中文配置

**常用开发工具**
- 交互式选择安装：7-Zip、Everything、Postman、DBeaver、Docker Desktop 等

## 项目结构

```
win-dev-setup/
├── setup.ps1                  # PowerShell 入口
├── setup.sh                   # 主安装器（交互菜单）
├── lib/
│   ├── utils.sh               # 公共函数库
│   └── mirrors.sh             # 国内镜像源配置
├── configs/                   # 配置模板
│   ├── git/.gitconfig
│   ├── bash/.bashrc
│   ├── bash/.bash_profile
│   ├── terminal/starship.toml
│   └── vscode/settings.json
├── scripts/                   # 模块安装脚本
│   ├── setup-git.sh
│   ├── setup-bash.sh
│   ├── setup-node.sh
│   ├── setup-python.sh
│   ├── setup-vscode.sh
│   ├── setup-terminal.sh
│   ├── setup-ssh.sh
│   ├── setup-claude.sh
│   └── setup-utils.sh
└── templates/                 # 交互模板
```

## 自定义

### 添加你自己的配置

1. Fork 本仓库
2. 修改 `configs/` 下的配置文件
3. 在 `scripts/setup-utils.sh` 的 `TOOLS` 数组中增删工具
4. 在 `setup.sh` 的 `MODULES` 数组中增删模块

### 本地覆盖

安装后会创建 `~/.bashrc.local`，放机子特定的配置（不会被更新覆盖）：

```bash
# ~/.bashrc.local
export JAVA_HOME="/c/Program Files/Java/jdk-17"
alias myproject="cd ~/projects/myproject"
```

## 镜像加速说明

本工具默认使用以下国内镜像：

| 工具 | 镜像源 |
|------|--------|
| npm | `https://registry.npmmirror.com` |
| pip | `https://pypi.tuna.tsinghua.edu.cn/simple` |
| Go | `https://goproxy.cn` |
| Cargo | `https://mirrors.ustc.edu.cn/crates.io-index/` |
| RubyGems | `https://gems.ruby-china.com/` |

## FAQ

**Q: 安装失败怎么办？**
每个模块独立运行，一个失败不影响其他。可以单独重跑失败的模块，或手动安装对应工具后再跑。

**Q: 已有配置会被覆盖吗？**
覆盖前会自动备份为 `原文件.bak.20260811_143000` 格式，随时可恢复。

**Q: 可以用 scoop 替代 winget 吗？**
当前优先使用 winget（Windows 原生，免安装）。欢迎 PR 添加 scoop 支持。

**Q: 支持 WSL 吗？**
本工具面向 Windows 原生 Git Bash 环境。WSL 请使用 Linux 版 dotfiles。

## License

MIT
