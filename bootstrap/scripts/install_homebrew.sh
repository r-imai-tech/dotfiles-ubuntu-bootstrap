#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# install_homebrew.sh
#   - Ubuntu 上で Homebrew をインストールし、
#     Bash と Fish の両方に恒久的に PATH を通すスクリプト
#
# 使い方:
#   chmod +x install_homebrew.sh
#   ./install_homebrew.sh
# ------------------------------------------------------------------------------

log() {
  printf '\e[32m[INFO]\e[0m %s\n' "$*"
}

# ------------------------------------------------------------------------------
# 関数: ファイルに同一行がなければ追記する
# ------------------------------------------------------------------------------
append_if_missing() {
  local line="$1"
  local file="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

# ------------------------------------------------------------------------------
# 1) Homebrew がインストールされていなければインストール
# ------------------------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew が見つからないため、インストールを開始します..."

  # 非対話モードで公式インストールスクリプトを実行
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  log "Homebrew のインストールが完了しました。"
else
  log "Homebrew は既にインストールされています。"
fi

# ------------------------------------------------------------------------------
# 2) Homebrew のプレフィックス（インストール先）を設定
#    デフォルトでは /home/linuxbrew/.linuxbrew にインストールされる
#    ※ 必要に応じて変更してください
# ------------------------------------------------------------------------------
BREW_PREFIX="/home/linuxbrew/.linuxbrew"

# ------------------------------------------------------------------------------
# 3) Bash 用の設定: ~/.bashrc に brew shellenv を追加
# ------------------------------------------------------------------------------
BASH_RC="$HOME/.bashrc"
BREW_SHELLENV="eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\""
log "bash に PATH 設定を追加します: $BASH_RC"
append_if_missing "$BREW_SHELLENV" "$BASH_RC"

# -- 即時反映（このスクリプトを実行しているシェル用） --
#    すでに brew がインストール済みの場合、brew shellenv が使えるようにする
if [ -f "${BREW_PREFIX}/bin/brew" ]; then
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fi

# ------------------------------------------------------------------------------
# 4) Fish 用の設定: ~/.config/fish/config.fish に PATH を追加
# ------------------------------------------------------------------------------
FISH_CONFIG="$HOME//dotfiles-ubuntu-bootstrap/config/dotfiles/fish/config.fish"
log "fish に PATH 設定を追加します: $FISH_CONFIG"

# Fish の設定ディレクトリを作成
mkdir -p "$(dirname "$FISH_CONFIG")"
touch "$FISH_CONFIG"

# Homebrew の bin を fish のパスに追加
append_if_missing "set -gx PATH ${BREW_PREFIX}/bin \$PATH" "$FISH_CONFIG"
# man, info のパスも必要なら追記
append_if_missing "set -gx MANPATH ${BREW_PREFIX}/share/man \$MANPATH" "$FISH_CONFIG"
append_if_missing "set -gx INFOPATH ${BREW_PREFIX}/share/info \$INFOPATH" "$FISH_CONFIG"

log "設定が完了しました。次回から bash と fish で Homebrew の PATH が有効になります。"