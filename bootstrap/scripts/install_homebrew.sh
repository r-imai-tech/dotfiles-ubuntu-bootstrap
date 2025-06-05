#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\e[32m[INFO]\e[0m %s\n' "$*"
}

#-------------------------------------------------------------------------------
# install_homebrew.sh
#  - Homebrew（Linuxbrew）をインストールするスクリプト
#  - どのユーザーが実行しても、インストール後は Bash シェルで自動的に `brew` が使えるように設定を追加
#  - 前提: install_apt_deps.sh 等で必要なパッケージ（curl, git, build-essential など）がすでにインストールされていること
#
# 使い方:
#   chmod +x install_homebrew.sh
#   ./install_homebrew.sh
#-------------------------------------------------------------------------------

# ─── 便利関数: ファイルに行が無ければ追記 ───────────────────────────────────
append_if_missing() {
  local line="$1" file="$2"
  # ファイルがなければ作成しておく
  mkdir -p "$(dirname "$file")"
  touch "$file"
  # 行単位で完全一致をチェックし、なければ追記
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

# ─── Homebrew インストール ─────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  log "【install_homebrew】Homebrew が見つからないため、インストールを開始します"
  # 非対話モードで Homebrew をインストール
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  log "【install_homebrew】Homebrew はすでにインストール済みです"
fi

# Homebrew がどこにインストールされたかを取得
BREW_PATH="$(command -v brew || true)"
if [ -z "$BREW_PATH" ]; then
  echo "[ERROR] Homebrew の実行ファイルが見つかりません。インストールに失敗した可能性があります。" >&2
  exit 1
fi
log "【install_homebrew】Homebrew のパス: $BREW_PATH"

# ─── Bash 用の設定を ~/.bashrc に追記 ─────────────────────────────────────────
BREW_PREFIX="$("$BREW_PATH" --prefix)"
# shellenv の eval 文をそのまま文字列として追加
BREW_SHELLENV="eval \"\$($BREW_PREFIX/bin/brew shellenv)\""

append_if_missing "" "$HOME/.bashrc"
append_if_missing "# ──────────────────────────────────────────────────────────" "$HOME/.bashrc"
append_if_missing "# Homebrew の環境変数を読み込む" "$HOME/.bashrc"
append_if_missing "$BREW_SHELLENV" "$HOME/.bashrc"
append_if_missing "# ──────────────────────────────────────────────────────────" "$HOME/.bashrc"
log "【install_homebrew】~/.bashrc に brew の shellenv 設定を追記しました"

# ─── 現在のシェルに即時反映 ───────────────────────────────────────────────────
log "【install_homebrew】現在のシェルに Homebrew の環境を反映します"
eval "$("$BREW_PATH" shellenv)"

log "【install_homebrew】完了: Homebrew がインストールされ、Bash にパスが通りました"