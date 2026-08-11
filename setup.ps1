# ============================================================
# Windows 开发环境一键配置 — PowerShell 入口
# ============================================================
# 用法（在 PowerShell 中运行）:
#   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
#   .\setup.ps1
# 或者一键远程运行:
#   powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.gitmirror.com/<user>/win-dev-setup/main/setup.ps1 | iex"
# ============================================================

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "Windows 开发环境安装器"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows 开发者环境一键配置" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- 检查是否以管理员运行（预检，不强制） ---
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "[WARN] 建议以管理员身份运行（部分工具安装需要管理员权限）" -ForegroundColor Yellow
    Write-Host "       右键 PowerShell → 以管理员身份运行" -ForegroundColor Yellow
    Write-Host ""
}

# --- 检查 winget ---
Write-Host "[INFO] 检查 winget..." -ForegroundColor Blue
$winget = Get-Command winget.exe -ErrorAction SilentlyContinue
if (-not $winget) {
    Write-Host "[WARN] winget 不可用" -ForegroundColor Yellow
    Write-Host "       安装 App Installer: https://apps.microsoft.com/detail/9nblggh4nns1" -ForegroundColor Yellow
    Write-Host "       或在 Microsoft Store 搜索 '应用安装程序'" -ForegroundColor Yellow
}
else {
    Write-Host "[OK]   winget 可用" -ForegroundColor Green
}

# --- 检查 Git Bash ---
Write-Host "[INFO] 检查 Git Bash..." -ForegroundColor Blue
$gitBashPaths = @(
    "C:\Program Files\Git\bin\bash.exe",
    "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe",
    "$env:USERPROFILE\scoop\apps\git\current\bin\bash.exe"
)

$bashPath = $null
foreach ($p in $gitBashPaths) {
    if (Test-Path $p) {
        $bashPath = $p
        break
    }
}

if (-not $bashPath) {
    Write-Host "[WARN] Git Bash 未找到" -ForegroundColor Yellow
    if ($winget) {
        Write-Host "[INFO] 正在通过 winget 安装 Git..." -ForegroundColor Blue
        winget install --id Git.Git --silent --accept-package-agreements --accept-source-agreements
        # 重新检查
        foreach ($p in $gitBashPaths) {
            if (Test-Path $p) {
                $bashPath = $p
                break
            }
        }
    }

    if (-not $bashPath) {
        Write-Host "[ERROR] Git Bash 安装失败或未找到" -ForegroundColor Red
        Write-Host "        请手动安装 Git: https://git-scm.com/download/win" -ForegroundColor Red
        Write-Host ""
        Write-Host "按任意键退出..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }

    Write-Host "[OK]   Git Bash 安装完成" -ForegroundColor Green
    Write-Host "[INFO] 请重新运行此脚本" -ForegroundColor Blue
    Write-Host ""
    Write-Host "按任意键退出..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

Write-Host "[OK]   Git Bash: $bashPath" -ForegroundColor Green

# --- 获取脚本所在目录（切换到项目根目录） ---
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($scriptDir)) {
    $scriptDir = Get-Location
}

Write-Host "[INFO] 启动安装器..." -ForegroundColor Blue
Write-Host ""

# --- 启动 Bash 安装器 ---
$env:MSYS2_PATH_TYPE = "inherit"
& $bashPath -c "cd '$scriptDir' && bash setup.sh"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  安装器已退出" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "按任意键关闭..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
