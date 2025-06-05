#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# install_homebrew.sh
#   - Ubuntu 上で Homebrew をインストールし、
#     Bash と Fish の両方に恒久的に PATH を通すスクリプト
#   - このスクリプトは source で実行してください (bootstrap.sh 内で source)
# ------------------------------------------------------------------------------

# ─────────────────────────────────────────────────────────────────────────────
# (1) リポジトリ内の config/dotfiles/fish を ~/.config/fish に移動する
# ─────────────────────────────────────────────────────────────────────────────

# まず、スクリプト自身のディレクトリを取得しておく
# ※ これにより、どこから呼んでも正しくパスを解決できます
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# リポジトリ内の元ディレクトリ
SRC_DIR="$DOTFILES_ROOT/config/dotfiles/fish"
# 移動先ディレクトリ
DEST_DIR="$HOME/.config"

# ~/.config ディレクトリがなければ作る
mkdir -p "$DEST_DIR"

# もし元ディレクトリが存在すれば、~/.config 以下に移動する
if [ -d "$SRC_DIR" ]; then
  echo "[INFO] 移動: ${SRC_DIR} → ${DEST_DIR}"
  mv "$SRC_DIR" "$DEST_DIR"/

  # 移動後、上位の空ディレクトリを削除しておく（※必要なら）
  #   例: config/dotfiles が空になったら消す
  PARENT_DIR="$DOTFILES_ROOT/config/dotfiles"
  if [ -d "$PARENT_DIR" ] && [ -z "$(ls -A "$PARENT_DIR")" ]; then
    rm -rf "$PARENT_DIR"
    echo "[INFO] 空になった $PARENT_DIR を削除しました"
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────

log() {
  printf '\e[32m[INFO]\e[0m %s\n' "$*"
}

bash ./bootstrap/scripts/install_apt_deps.sh
bash ./bootstrap/scripts/install_fish.sh

# ------------------------------------------------------------------------------
# ファイルに同一行がなければ追記する関数
# ------------------------------------------------------------------------------
append_if_missing() {
  local line="$1"
  local file="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

echo
log "Homebrew のインストールを開始します"

# ------------------------------------------------------------------------------
# 1) Homebrew がインストールされていなければインストール
# ------------------------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
  log "Homebrew が見つからないため、非対話モードでインストールを実行します..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  log "Homebrew のインストールが完了しました。"
else
  log "Homebrew は既にインストール済みです。"
fi

# ------------------------------------------------------------------------------
# 2) Homebrew のプレフィックス設定
#    デフォルトのインストール先: /home/linuxbrew/.linuxbrew
# ------------------------------------------------------------------------------
BREW_PREFIX="/home/linuxbrew/.linuxbrew"

# ------------------------------------------------------------------------------
# 3) Bash 用設定: ~/.bashrc に brew shellenv を追記
# ------------------------------------------------------------------------------
BASH_RC="$HOME/.bashrc"
BREW_SHELLENV="eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\""
log "~/.bashrc に Homebrew 環境設定を追加します: $BASH_RC"
append_if_missing "$BREW_SHELLENV" "$BASH_RC"

# -- 即時反映（この bash セッション向け） --
if [ -x "${BREW_PREFIX}/bin/brew" ]; then
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fi

# ------------------------------------------------------------------------------
# 4) Fish 用設定: ~/.config/fish/config.fish に PATH を追加
# ------------------------------------------------------------------------------
FISH_CONFIG="$HOME/dotfiles-ubuntu-bootstrap/config/dotfiles/fish/config.fish"
log "Fish シェル用に Homebrew の PATH を追加します: $FISH_CONFIG"

mkdir -p "$(dirname "$FISH_CONFIG")"
touch "$FISH_CONFIG"

# fish は login セッションでなくても config.fish を読み込むので、ここに追記すれば
# install_fisher.sh や install_fish_plugins_extra.sh 内で fish コマンドを使っても
# Homebrew のパスが通った状態になります。
append_if_missing "set -gx PATH ${BREW_PREFIX}/bin \$PATH" "$FISH_CONFIG"
append_if_missing "set -gx MANPATH ${BREW_PREFIX}/share/man \$MANPATH" "$FISH_CONFIG"
append_if_missing "set -gx INFOPATH ${BREW_PREFIX}/share/info \$INFOPATH" "$FISH_CONFIG"

log "Fish の設定に Homebrew の PATH を追記しました。"

echo
log "install_homebrew.sh が完了しました。"

# ※ このスクリプトは source で実行してください。bash に brew の PATH を即時反映するためです。
#   Bootstrap.sh 内では以下のように実行します:
#     source ./bootstrap/scripts/install_homebrew.sh

bash ./bootstrap/scripts/install_brew_packages.sh
bash ./bootstrap/scripts/install_fisher.sh
bash ./bootstrap/scripts/install_fish_plugins_extra.sh

exec fish

log "完了"
