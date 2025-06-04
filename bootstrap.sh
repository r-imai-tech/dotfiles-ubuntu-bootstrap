#!/usr/bin/env bash
set -euo pipefail

#-------------------------------------------------------------------------------
# bootstrap.sh
#  - 各モジュールスクリプトを順に呼び出して一括セットアップする
#
# 使い方:
#   chmod +x bootstrap.sh
#   ./bootstrap.sh
#-------------------------------------------------------------------------------

echo
echo "========================================"
echo "[INFO] 環境構築を開始します"
echo "========================================"
echo

# ─── ① APT deps 導入 ──────────────────────────────────
bash ./bootstrap/scripts/install_apt_deps.sh

# ─── ② Homebrew インストール ───────────────────────────
bash ./bootstrap/scripts/install_homebrew.sh

# ─── ③ brew パッケージ (git, grep) インストール ────────
bash ./bootstrap/scripts/install_brew_packages.sh

# ─── ④ Fish インストール＆デフォルト化 ───────────────
bash ./bootstrap/scripts/install_fish.sh

# ─── ⑤ fisher インストール ───────────────
bash ./bootstrap/scripts/install_fisher.sh

echo
echo "========================================"
echo "[INFO] 全体のセットアップが完了しました"
echo "  • 一度ログアウト／再ログイン、または新規ターミナルを開いて"
echo "    Fish シェルがデフォルトとして起動することを確認してください"
echo "========================================"