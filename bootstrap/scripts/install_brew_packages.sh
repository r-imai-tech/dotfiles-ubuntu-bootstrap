#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '\e[32m[INFO]\e[0m %s\n' "$*"
}

#-------------------------------------------------------------------------------
# install_brew_packages.sh
#  - Homebrew 経由で git・GNU grep をインストール（またはアップデート）
#  - eza: Homebrew → Apt フォールバック
#  - zoxide: Homebrew ボトルがあればインストール
#  - ghq: ARM64 向けボトルがなければ Go を使ってインストール
#  - 前提: install_homebrew.sh が完了していること
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
    sudo apt update
    sudo apt install -y eza
    log "  • eza を APT でインストールしました: $(which eza)"
  fi
else
  log "  • eza は既にインストール済み: $(which eza)"
fi

# 4) zoxide のインストール（Homebrew ボトルがあれば Homebrew でインストール）
log "【install_brew_packages】Homebrew 経由で zoxide をインストールまたは確認"
if ! brew list zoxide &>/dev/null; then
  if brew install zoxide; then
    log "  • zoxide を Homebrew でインストールしました: $(which zoxide)"
  else
    log "  • zoxide の Homebrew ボトルが利用できないため、Apt またはソースビルドを検討してください"
    # ここで Apt へフォールバックする場合は、以下の例のように Rust toolchain を使ってビルドできます。
    # sudo apt update
    # sudo apt install -y cargo
    # cargo install zoxide
    # log "  • zoxide を Cargo でビルドしてインストールしました: $(which zoxide)"
  fi
else
  log "  • zoxide は既にインストール済み: $(which zoxide)"
fi

# 5) ghq のインストール
#    ARM64 向けボトルが存在しない場合、Go を使ってビルド or go install にフォールバック
log "【install_brew_packages】Homebrew 経由で ghq をインストールまたは確認"
if brew list ghq &>/dev/null; then
  log "  • ghq は既にインストール済み: $(which ghq)"
else
  # 5-1) まずは通常通りインストールを試みる
  if brew install ghq; then
    log "  • ghq を Homebrew でインストールしました: $(which ghq)"
  else
    log "  • ghq の瓶（ボトル）が見つからなかったため、ビルドまたは Go install に移行します"
    # 5-2) Go がインストールされているかチェック。無ければ apt で入れる
    if ! command -v go &>/dev/null; then
      log "  • Go が見つからないため、apt でインストールします"
      sudo apt update
      sudo apt install -y golang-go
      log "  • Go をインストールしました: $(which go)"
    fi

    # 5-3) build-essential が入っているか確認（入っていなければ apt で入れる）
    if ! dpkg -s build-essential &>/dev/null; then
      log "  • build-essential が見つからないため、apt でインストールします"
      sudo apt update
      sudo apt install -y build-essential
      log "  • build-essential をインストールしました"
    fi

    # 5-4) 再度 Homebrew でビルドしてみる
    if brew install --build-from-source ghq; then
      log "  • ghq をソースからビルドしてインストールしました: $(which ghq)"
    else
      # 5-5) それでも失敗した場合、go install で最新版をインストール
      log "  • Homebrew ソースビルドにも失敗したため、go install で ghq をインストールします"
      GO_BIN="$(go env GOPATH)/bin"
      export PATH="$GO_BIN:$PATH"
      go install github.com/x-motemen/ghq@latest
      log "  • ghq を go install でインストールしました: $(which ghq)"
    fi
  fi
fi

# 6) インストール状況確認（出力例）
log "  • git のパス: $(which git)"
log "  • grep のパス: $(which grep)"
log "  • eza のパス: $(which eza)"
log "  • ghq のパス: $(which ghq)"
log "  • zoxide のパス: $(which zoxide)"

log "【install_brew_packages】完了: git, grep, eza, ghq, zoxide が導入されました"