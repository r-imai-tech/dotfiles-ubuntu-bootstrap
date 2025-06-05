#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\e[32m[INFO]\e[0m %s\n' "$*"
}

#-------------------------------------------------------------------------------
# install_brew_packages.sh
#  - Homebrew 経由で Git・GNU grep をインストール（またはアップデート）
#  - eza: Homebrew でのインストールが失敗したら Apt でインストールへフォールバック
#  - zoxide: Homebrew ボトルがあればインストール
#  - ghq: ARM64 向けボトルがなければソースビルド or Go install へフォールバック
#  - 前提: install_homebrew.sh が完了していること
#
# 使い方:
#   chmod +x install_brew_packages.sh
#   ./install_brew_packages.sh
#-------------------------------------------------------------------------------

# 1) brew コマンドが存在しなければ、Homebrew の環境を読み込む
if ! command -v brew &>/dev/null; then
  if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    log "【install_brew_packages】brew が見つからないため、環境変数を反映します"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    echo "[ERROR] Brew が見つかりません。install_homebrew.sh の実行を確認してください。" >&2
    exit 1
  fi
fi

# 2) Git と GNU grep のインストール（またはアップデート）
log "【install_brew_packages】brew で git, grep をインストール（またはアップデート）"
brew install git grep

# 3) eza のインストール（Homebrew → Apt フォールバック）
log "【install_brew_packages】Homebrew 経由で eza をインストールまたは確認"
if ! brew list eza &>/dev/null; then
  if brew install eza; then
    log "  • eza を Homebrew でインストールしました: $(which eza)"
  else
    log "  • eza の Homebrew ボトルが利用できないため、APT からインストールを試みます"
    # 以下では sudo を使って apt install します。必要に応じてパスワード入力が求められます。
    sudo apt update
    sudo apt install -y eza
    log "  • eza を APT でインストールしました: $(which eza)"
  fi
else
  log "  • eza は既にインストール済み: $(which eza)"
fi

# 4) zoxide のインストール（ARM64 向けボトルがあれば Homebrew でインストール）
log "【install_brew_packages】Homebrew 経由で zoxide をインストールまたは確認"
if ! brew list zoxide &>/dev/null; then
  if brew install zoxide; then
    log "  • zoxide を Homebrew でインストールしました: $(which zoxide)"
  else
    log "  • zoxide の Homebrew ボトルが利用できないため、Apt またはソースビルドを検討してください"
    # ここで Apt へフォールバックする場合、以下の例のように rust cargo を使ってビルド可能です。
    # sudo apt update
    # sudo apt install -y cargo
    # cargo install zoxide
    # log "  • zoxide を Cargo でビルドしてインストールしました: $(which zoxide)"
  fi
else
  log "  • zoxide は既にインストール済み: $(which zoxide)"
fi

# 5) ghq のインストール
#    ARM64 ではボトルが存在しない場合があるため、ビルドにフォールバック
log "【install_brew_packages】Homebrew 経由で ghq をインストールまたは確認"
if brew list ghq &>/dev/null; then
  log "  • ghq は既にインストール済み: $(which ghq)"
else
  # 試しに通常インストールを試みる
  if brew install ghq; then
    log "  • ghq を Homebrew でインストールしました: $(which ghq)"
  else
    log "  • ghq のボトルが見つからなかったため、ソースからビルドを試みます"
    if brew install --build-from-source ghq; then
      log "  • ghq をソースからビルドしてインストールしました: $(which ghq)"
    else
      # Homebrew ビルドにも失敗した場合、Go install でフォールバック
      if command -v go &>/dev/null; then
        log "  • Go が検出されたため、'go install' で ghq をインストールします"
        GO_BIN=$(go env GOPATH)/bin
        export PATH="$GO_BIN:$PATH"
        go install github.com/x-motemen/ghq@latest
        log "  • ghq を Go install でインストールしました: $(which ghq)"
      else
        echo "[ERROR] ghq のインストールに失敗しました。Go がインストールされていないか、ビルド環境に問題があります。" >&2
        exit 1
      fi
    fi
  fi
fi

# 6) インストール状況確認
log "  • git のパス: $(which git)"
log "  • grep のパス: $(which grep)"
log "  • eza のパス: $(which eza)"
log "  • ghq のパス: $(which ghq)"
log "  • zoxide のパス: $(which zoxide)"

log "【install_brew_packages】完了: git, grep, eza, ghq, zoxide が導入されました"