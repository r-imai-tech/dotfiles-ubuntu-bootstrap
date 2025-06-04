#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\e[32m[INFO]\e[0m %s\n' "$*"
}

#-------------------------------------------------------------------------------
# install_fish.sh
#  - Ubuntu の APT リポジトリ更新および Fish シェルの導入
#  - 前提: install_apt_deps.sh が完了していること
#
# 使い方:
#   chmod +x install_fish.sh
#   ./install_fish.sh
#-------------------------------------------------------------------------------

# 1) APT のリポジトリ更新（すでに install_apt_deps.sh で update 済みでも念のため実行）
log "【install_fish】apt-get update"
sudo apt-get update -y

# 2) Fish シェルをインストール
log "【install_fish】インストール: sudo apt-get install -y fish"
sudo apt-get install -y fish

# 3) /etc/shells に fish が登録されていなければ追記
FISH_PATH="$(which fish)"
if ! grep -q "^${FISH_PATH}\$" /etc/shells; then
  log "【install_fish】/etc/shells に '${FISH_PATH}' を追加"
  echo "${FISH_PATH}" | sudo tee -a /etc/shells >/dev/null
else
  log "【install_fish】/etc/shells に '${FISH_PATH}' はすでに登録済み"
fi

# 4) デフォルトシェルを Fish に変更
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$CURRENT_SHELL" != "$FISH_PATH" ]; then
  log "【install_fish】デフォルトシェルを Fish に変更: chsh -s ${FISH_PATH}"
  sudo chsh -s "${FISH_PATH}" "$USER"
  log "  → 次回ログインから Fish がデフォルトシェルになります"
else
  log "【install_fish】デフォルトシェルは既に Fish です"
fi

log "【install_fish】完了: Fish のインストール＆シェル変更を実施しました"