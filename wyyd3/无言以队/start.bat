@echo off
chcp 65001 >nul
title 无言以队 · 舞弊审计调查辅助台 启动器
setlocal enabledelayedexpansion

echo.
echo  ============================================================
echo    无言以队 · 舞弊审计调查辅助台
echo    金融业舞弊审计调查岗位 AI 工作助理
echo  ============================================================
echo.

cd /d "%~dp0"

REM ---------- 检查 Node.js ----------
where node >nul 2>nul
if errorlevel 1 (
  echo  [!] 未检测到 Node.js。
  echo.
  echo      本项目的后端安全代理需要 Node.js 运行环境（建议 16 及以上版本）。
  echo      请访问 https://nodejs.org 下载安装后重新运行本脚本。
  echo.
  echo      提示：即使没有 Node.js，您也可以直接双击 index.html
  echo            以「演示数据」离线模式使用全部功能。
  echo.
  pause
  start "" "index.html"
  exit /b 0
)

for /f "tokens=*" %%v in ('node --version') do set NODE_VER=%%v
echo  [OK] Node.js 版本：!NODE_VER!

REM ---------- 检查依赖 ----------
if not exist "node_modules\mysql2" (
  echo.
  echo  [1/3] 首次运行，正在安装依赖（mysql2）...
  call npm.cmd install --omit=dev
  if errorlevel 1 (
    echo.
    echo  [!] 依赖安装失败。
    echo      若处于离线环境，可直接双击 index.html 使用「演示数据」模式。
    echo.
    pause
    start "" "index.html"
    exit /b 0
  )
) else (
  echo  [1/3] 依赖已就绪
)

REM ---------- 启动后端代理 ----------
echo  [2/3] 启动后端安全代理服务（http://127.0.0.1:3001）...
start "wuyan-proxy - 无言以队后端服务" cmd /c "node server.js & echo. & echo 服务已停止，按任意键关闭窗口 & pause >nul"

REM 等待服务就绪
echo        等待服务就绪...
set /a WAIT_COUNT=0
:WAIT_LOOP
timeout /t 1 >nul
set /a WAIT_COUNT+=1
powershell -NoProfile -Command "try { $r = Invoke-WebRequest -Uri 'http://127.0.0.1:3001/api/health' -UseBasicParsing -TimeoutSec 2; if ($r.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>nul
if errorlevel 1 (
  if !WAIT_COUNT! LSS 12 goto WAIT_LOOP
  echo  [!] 服务启动超时，仍尝试打开前端页面。
) else (
  echo  [OK] 后端服务已就绪
)

REM ---------- 打开前端 ----------
echo  [3/3] 打开前端应用...
start "" "index.html"

echo.
echo  ============================================================
echo    启动完成
echo  ============================================================
echo.
echo    前端页面 : index.html
echo    后端接口 : http://127.0.0.1:3001/api
echo    健康检查 : http://127.0.0.1:3001/api/health
echo.
echo    提示：
echo      - 顶部可切换「演示数据 / 连接数据库」两种模式
echo      - 若使用离线演示模式，可直接双击 index.html
echo      - 关闭后端服务窗口即可停止服务
echo.
echo  ============================================================
echo.
pause
endlocal
