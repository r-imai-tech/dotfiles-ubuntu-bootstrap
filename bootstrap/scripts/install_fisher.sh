#!/usr/bin/env bash
set -euo pipefail

#-------------------------------------------------------------------------------
# install_fisher.sh
#  - Fish プラグインマネージャー「Fisher」をインストールする
#  - Fish がインストール済みであることを前提とする
#
# 使い方:
#   chmod +x install_fisher.sh
#   ./install_fisher.sh
#-------------------------------------------------------------------------------

log() {
  printf '\e[32m[INFO]\e[0m %s\n' "$*"
}

# 1) fish がインストール済みか確認
if ! command -v fish &>/dev/null; then
  echo "[ERROR] fish シェルが見つかりません。先に fish をインストールしてください。" >&2
  exit 1
fi
log "Fish がインストール済みです: $(which fish)"

# 2) ~/.config/fish/functions ディレクトリがあるか確認し、なければ作成
FISH_FUNC_DIR="$HOME/.config/fish/functions"
if [ ! -d "$FISH_FUNC_DIR" ]; then
  log "ディレクトリ '$FISH_FUNC_DIR' を作成します"
  mkdir -p "$FISH_FUNC_DIR"
fi

# 3) Fisher をインストール（Fish の CLI コマンドとして実行）
#    └ curl を実行して取得したスクリプトを一度 fish で読み込み、fisher コマンドを作成
log "Fisher をインストールしています..."
fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'

# 4) インストール結果の確認
if fish -c 'type -q fisher'; then
  log "Fisher のインストールが完了しました"
  log "  • 実行可能パス: $(fish -c "which fisher" | tr -d "\r\n")"
else
  echo "[ERROR] Fisher のインストールに失敗しました。" >&2
  exit 1
fi

# 5) 終了メッセージ
log "========================================"
log "Fisher のインストール処理が完了しました。"
log "次に ~/.config/fish/config.fish にプラグイン一覧を追記し、"
log "魚の鞭（fish shell）を再起動するとプラグインが有効になります。"
log "========================================"