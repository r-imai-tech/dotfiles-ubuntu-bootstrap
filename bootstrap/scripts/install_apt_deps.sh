#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\e[32m[INFO]\e[0m %s\n' "$*"
}

#-------------------------------------------------------------------------------
# install_apt_deps.sh
#  - Ubuntu の APT リポジトリ更新および
#    build-essential, procps, curl, file, git のインストール
#
# 使い方:
#   chmod +x install_apt_deps.sh
#   ./install_apt_deps.sh
#-------------------------------------------------------------------------------

log "【install_apt_deps】APT リポジトリ更新"
sudo apt-get update -y

log "【install_apt_deps】ビルド依存ツール群をインストール: build-essential, procps, curl, file, git"
sudo apt-get install -y build-essential procps curl file git tree

log "【install_apt_deps】完了: APT deps インストールが終了しました"