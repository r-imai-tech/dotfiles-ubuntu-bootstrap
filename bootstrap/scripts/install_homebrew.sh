#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\e[32m[INFO]\e[0m %s\n' "$*"
}

#-------------------------------------------------------------------------------
# install_homebrew.sh
#  - Homebrew（Linuxbrew）をインストールするスクリプト
#  - どのユーザーが実行しても、インストール後はシェル(bash, sh, fish)で自動的に `brew` が使えるように設定を追加
#  - 前提: install_apt_deps.sh がすでに完了していること
#
# 使い方:
#   chmod +x install_homebrew.sh
#   ./install_homebrew.sh
#-------------------------------------------------------------------------------

# 1) brew コマンドが存在しなければ、インストール開始
if ! command -v brew &>/dev/null; then
  log "【install_homebrew】Homebrew が見つからないため、インストールを開始します"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # インストール完了後、実際にインストールされた brew のパスを取得
  BREW_PATH="$(command -v brew)"
  if [ -z "$BREW_PATH" ]; then
    echo "[ERROR] Homebrew のインストールに失敗した可能性があります。" >&2
    exit 1
  fi

  log "【install_homebrew】Homebrew の環境変数設定をシェル用ファイルに追記"

  # 2) ~/.profile に追記（ログインシェル／POSIX 準拠シェル向け）
  PROFILE_FILE="$HOME/.profile"
  mkdir -p "$(dirname "$PROFILE_FILE")"
  touch "$PROFILE_FILE"
  if ! grep -Fxq "eval \"\$($BREW_PATH shellenv)\"" "$PROFILE_FILE"; then
    {
      echo ""
      echo "# ──────────────────────────────────────────────────────────"
      echo "# Homebrew の環境変数を読み込む"
      echo "eval \"\$($BREW_PATH shellenv)\""
      echo "# ──────────────────────────────────────────────────────────"
    } >> "$PROFILE_FILE"
    log "  • ~/.profile に追加しました"
  else
    log "  • ~/.profile には既に設定済みです"
  fi

  # 3) ~/.bashrc に追記（インタラクティブな bash ログイン／非ログインシェル向け）
  BASHRC_FILE="$HOME/.bashrc"
  mkdir -p "$(dirname "$BASHRC_FILE")"
  touch "$BASHRC_FILE"
  if ! grep -Fxq "eval \"\$($BREW_PATH shellenv)\"" "$BASHRC_FILE"; then
    {
      echo ""
      echo "# ──────────────────────────────────────────────────────────"
      echo "# Homebrew の環境変数を読み込む"
      echo "eval \"\$($BREW_PATH shellenv)\""
      echo "# ──────────────────────────────────────────────────────────"
    } >> "$BASHRC_FILE"
    log "  • ~/.bashrc に追加しました"
  else
    log "  • ~/.bashrc には既に設定済みです"
  fi

  # 4) ~/.config/fish/config.fish に追記（Fish シェル向け）
  FISH_CONFIG_DIR="$HOME/.config/fish"
  FISH_CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"
  mkdir -p "$FISH_CONFIG_DIR"
  touch "$FISH_CONFIG_FILE"
  # 動的に command -v brew の結果を使う設定を追加
  if ! grep -Fxq 'if test -f (command -v brew)' "$FISH_CONFIG_FILE"; then
    {
      echo ""
      echo "# ──────────────────────────────────────────────────────────"
      echo "# Homebrew (Linuxbrew) のパスを Fish で通す"
      echo "if test -f (command -v brew)"
      echo "    eval (brew shellenv)"
      echo "end"
      echo "# ──────────────────────────────────────────────────────────"
    } >> "$FISH_CONFIG_FILE"
    log "  • ~/.config/fish/config.fish に追加しました"
  else
    log "  • ~/.config/fish/config.fish には既に設定済みです"
  fi

  log "【install_homebrew】現在のシェルに Homebrew のパスを反映"
  eval "$($BREW_PATH shellenv)"
else
  # brew が既にインストール済み
  BREW_PATH="$(command -v brew)"
  log "【install_homebrew】Homebrew はすでにインストール済み: $BREW_PATH"

  # PATH に brew が通っていなければ現在のシェルに追加
  if ! echo "$PATH" | grep -q "$(dirname "$BREW_PATH")"; then
    log "【install_homebrew】Homebrew のパスを現在のシェルに追加"
    eval "$($BREW_PATH shellenv)"
  fi

  # 既存設定をチェックし、不足分を追記する
  PROFILE_FILE="$HOME/.profile"
  touch "$PROFILE_FILE"
  if ! grep -Fxq "eval \"\$($BREW_PATH shellenv)\"" "$PROFILE_FILE"; then
    {
      echo ""
      echo "# ──────────────────────────────────────────────────────────"
      echo "# Homebrew の環境変数を読み込む"
      echo "eval \"\$($BREW_PATH shellenv)\""
      echo "# ──────────────────────────────────────────────────────────"
    } >> "$PROFILE_FILE"
    log "  • ~/.profile に追記しました"
  fi

  BASHRC_FILE="$HOME/.bashrc"
  touch "$BASHRC_FILE"
  if ! grep -Fxq "eval \"\$($BREW_PATH shellenv)\"" "$BASHRC_FILE"; then
    {
      echo ""
      echo "# ──────────────────────────────────────────────────────────"
      echo "# Homebrew の環境変数を読み込む"
      echo "eval \"\$($BREW_PATH shellenv)\""
      echo "# ──────────────────────────────────────────────────────────"
    } >> "$BASHRC_FILE"
    log "  • ~/.bashrc に追記しました"
  fi

  FISH_CONFIG_DIR="$HOME/.config/fish"
  FISH_CONFIG_FILE="$FISH_CONFIG_DIR/config.fish"
  mkdir -p "$FISH_CONFIG_DIR"
  touch "$FISH_CONFIG_FILE"
  if ! grep -Fxq 'if test -f (command -v brew)' "$FISH_CONFIG_FILE"; then
    {
      echo ""
      echo "# ──────────────────────────────────────────────────────────"
      echo "# Homebrew (Linuxbrew) のパスを Fish で通す"
      echo "if test -f (command -v brew)"
      echo "    eval (brew shellenv)"
      echo "end"
      echo "# ──────────────────────────────────────────────────────────"
    } >> "$FISH_CONFIG_FILE"
    log "  • ~/.config/fish/config.fish に追記しました"
  fi
fi

log "【install_homebrew】完了: Homebrew がインストールされました"