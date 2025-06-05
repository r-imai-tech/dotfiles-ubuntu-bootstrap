#!/usr/bin/env bash
# -------------------------------------------------------------------
# install_fish_plugins_extra.sh
# Fisher を使って Fish シェル用のプラグインを一括インストールする
# -------------------------------------------------------------------
set -euo pipefail

echo "[INFO] Installing extra Fish plugins via Fisher..."

# 1. Tide (高機能プロンプトテーマ v5)
fish -c 'fisher install ilancosman/tide@v5'          # Tide v5 を導入

# 2. zoxide (スマートなディレクトリジャンプ)
fish -c 'fisher install kidonng/zoxide.fish'         # zoxide.fish プラグインを導入

# 3. ghq (リポジトリ管理) + 補完とキーバインド
fish -c 'fisher install decors/fish-ghq'             # fish-ghq プラグインを導入

# 4. eza (ls 代替) 用プラグイン
fish -c 'fisher install givensuman/fish-eza'         # fish-eza プラグインを導入

# 5. fzf 連携プラグイン（既に brew インストール済みの場合でも補完を有効化）
fish -c 'fisher install PatrickF1/fzf.fish'          # fzf.fish プラグインを導入

# 6. nvm for Fish（Node.js バージョン管理。必要に応じて）
fish -c 'fisher install jorgebucaran/nvm.fish'       # nvm.fish プラグインを導入

# 7. done（長時間処理完了通知）
fish -c 'fisher install franciscolourenco/done'      # done プラグインを導入

echo "[INFO] Fish plugins installation complete."