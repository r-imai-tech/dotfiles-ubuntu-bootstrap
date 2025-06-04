# Dotfiles & Bootstrap Scripts

このリポジトリは、Ubuntu（およびその他の Linux 環境）上で **Fish シェル** と **Fisher（Fish 用プラグインマネージャー）** を導入する一連の手順を自動化・管理するものです。以下ではリポジトリの使い方（クローン→設定→Bootstrap）を網羅的に示します。

---

## 目次

1. [概要](#概要)
2. [ディレクトリ構成](#ディレクトリ構成)
3. [前提条件](#前提条件)
4. [リポジトリのクローンとBootstrap手順](#リポジトリのクローンとbootstrap手順)

   1. [リポジトリをクローン](#1-リポジトリをクローン)
   2. [シンボリックリンクの作成](#2-シンボリックリンクの作成)
   3. [Bootstrapスクリプトの実行](#3-bootstrapスクリプトの実行)
   4. [Fishを再起動して動作確認](#4-fishを再起動して動作確認)
5. [スクリプト一覧と役割](#スクリプト一覧と役割)

   1. [install\_apt\_deps.sh](#install_apt_depssh)
   2. [install\_homebrew.sh](#install_homebrewsh)
   3. [install\_brew\_packages.sh](#install_brew_packagessh)
   4. [install\_fish.sh](#install_fishsh)
   5. [install\_fisher.sh](#install_fishersh)
6. [Fish 設定ファイルの構成](#fish-設定ファイルの構成)

   1. [config.fish](#configfish)
   2. [functions/fishfile](#functionsfishfile)
   3. [その他のディレクトリ](#その他のディレクトリ)
7. [Fisher を使ったプラグイン管理](#fisher-を使ったプラグイン管理)
8. [日常的な更新・メンテナンス](#日常的な更新・メンテナンス)
9. [トラブルシューティング](#トラブルシューティング)
10. [その他の注意事項](#その他の注意事項)

---

## 概要

* **目的**: Fish シェル環境を整備し、Fisher を導入してプラグイン管理を行う。
* **対象範囲**: サーバー依存のビルド依存ツール導入から Fish→Fisher インストールまで。
* **将来拡張**: Neovim、tmux、lazygit、mise などの追加導入は別スクリプトで随時拡張予定。

---

## ディレクトリ構成

```
~/dotfiles
├── bootstrap.sh              # マスター実行スクリプト
├── bootstrap
│   └── scripts
│       ├── install_apt_deps.sh
│       ├── install_homebrew.sh
│       ├── install_brew_packages.sh
│       ├── install_fish.sh
│       └── install_fisher.sh
└── config
    └── dotfiles
        └── fish
            ├── completions
            │   └── fisher.fish
            ├── conf.d
            ├── config.fish
            ├── fish_plugins
            ├── fish_variables
            ├── functions
            │   └── fisher.fish
            └── themes
```

* **bootstrap.sh**: 一連のインストールスクリプトを順番に実行する。
* **bootstrap/scripts/**: APT deps → Homebrew → brew tools → Fish → Fisher を個別にインストールするシェルスクリプト。
* **config/dotfiles/fish/**: Fish の設定ファイル群を格納。最終的に `~/.config/fish/` にシンボリックリンクで反映する。

---

## 前提条件

1. **Linux（Ubuntu/Debian 系推奨）** または WSL/Orbstack 環境
2. **git** が利用できること
3. **sudo 権限** を持つユーザーであること
4. **インターネット接続** があること

---

## リポジトリのクローンとBootstrap手順

### 1. リポジトリをクローン

```bash
# 任意のディレクトリに移動し、リポジトリをクローン
cd ~
git clone https://github.com/<ユーザー名>/dotfiles-fish-bootstrap.git ~/dotfiles
cd ~/dotfiles
```

* `<ユーザー名>` は自身の GitHub ユーザー名に置き換えてください。
* ディレクトリ名 `~/dotfiles` は任意で変更可。

### 2. シンボリックリンクの作成

Fish 設定ファイルを `$HOME/.config/fish` に反映します。

```bash
# ~/.config/fish をリポジトリ内の設定にリンク
ln -sfn ~/dotfiles/config/dotfiles/fish ~/.config/fish
```

* 既存の `~/.config/fish` がある場合は上書きされます。
* 他の設定（テーマや補完）も同様にリンクして使います。

### 3. Bootstrapスクリプトの実行

```bash
# 初回のみ実行権限を付与
chmod +x ~/dotfiles/bootstrap.sh

# 各種インストール処理を順番に一括実行
~/dotfiles/bootstrap.sh
```

* スクリプトは以下の順で処理を行います。

  1. `install_apt_deps.sh` → APT リポジトリ更新＆ビルド依存ツール導入
  2. `install_homebrew.sh` → Homebrew（Linuxbrew）インストール
  3. `install_brew_packages.sh` → Git・grep・fzf 等を brew でインストール
  4. `install_fish.sh` → Fish シェルのインストール＆デフォルト化
  5. `install_fisher.sh` → Fisher（プラグイン管理）インストール

* 実行中はログが順次表示され、どこで何が実行されているか確認できます。

### 4. Fishを再起動して動作確認

Bootstrapが正常終了したら、Fish がデフォルトシェルとして立ち上がるか確認します。

```bash
# 現在のセッションを Fish に置き換え
exec fish

# シェルが Fish になっているか確認
echo $SHELL
# => /usr/bin/fish などが表示される

# Fisher がインストールされたか確認
type -q fisher; and echo "Fisher がインストールされています"
```

* Fisher コマンドが使えるようになっていれば、プラグイン管理の準備完了です。

---

## スクリプト一覧と役割

### install\_apt\_deps.sh

* **目的**: APT リポジトリ更新およびビルド依存ツール（build-essential, procps, curl, file, git）をインストール
* **実行例**:

  ```bash
  bash bootstrap/scripts/install_apt_deps.sh
  ```
* **ポイント**:

  * Homebrew や Fish のビルドに必要な基本ツールを事前に揃える。

---

### install\_homebrew\.sh

* **目的**: Homebrew（Linuxbrew）を自動インストールし、環境変数を設定
* **実行例**:

  ```bash
  bash bootstrap/scripts/install_homebrew.sh
  ```
* **ポイント**:

  * すでに `brew` コマンドが存在する場合はスキップ。
  * インストール後、`~/.profile` に `eval "$(brew shellenv)"` を追記し、現行シェルにも反映する。

---

### install\_brew\_packages.sh

* **目的**: Homebrew がインストール済みか確認し、Git・GNU grep・fzf などをインストール
* **実行例**:

  ```bash
  bash bootstrap/scripts/install_brew_packages.sh
  ```
* **ポイント**:

  * `brew` コマンドが PATH 上にない場合は `eval "$(brew shellenv)"` で環境を展開。
  * 一度に複数の brew パッケージを導入することで手順を簡素化。

---

### install\_fish.sh

* **目的**: Ubuntu の APT から Fish シェルをインストールし、`sudo chsh` でデフォルトログインシェルを Fish に変更
* **実行例**:

  ```bash
  bash bootstrap/scripts/install_fish.sh
  ```
* **ポイント**:

  * Orbstack やクラウド環境ではユーザーのパスワードが未設定のため、`sudo chsh -s $(which fish) $USER` を利用。
  * `/etc/shells` に Fish のパスが未登録の場合は自動で追記。

---

### install\_fisher.sh

* **目的**: Fish シェル上で Fisher（プラグイン管理ツール）をインストール
* **実行例**:

  ```bash
  bash bootstrap/scripts/install_fisher.sh
  ```
* **ポイント**:

  * Fish がインストール済みであることが前提。
  * `curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher` を実行し、`fisher` コマンドを有効化。

---

## Fish 設定ファイルの構成

### config.fish

* **場所**: `config/dotfiles/fish/config.fish`

* **役割**: Fish 起動時に最初に読み込まれるメイン設定ファイル

* **主な内容例**:

  ```fish
  # 環境変数定義
  set -g -x EDITOR nvim
  set -g -x LANG ja_JP.UTF-8

  # conf.d/ 配下のスクリプトをすべて読み込む
  for file in $HOME/.config/fish/conf.d/*.fish
    source $file
  end

  # functions/ をパスに追加
  set -g -x PATH $HOME/.config/fish/functions $PATH

  # Fisher を使って fishfile を一括インストール
  if type -q fisher
    fisher install (cat $HOME/.config/fish/functions/fishfile)
  end

  # completions/ 配下の補完スクリプトを読み込む
  for file in $HOME/.config/fish/completions/*.fish
    source $file
  end
  ```

* **ポイント**:

  * `conf.d/` や `functions/` を活用して設定を階層化する。
  * `functions/fishfile` を元にプラグインを自動同期。

---

### functions/fishfile

* **場所**: `config/dotfiles/fish/functions/fishfile`

* **役割**: Fisher でインストールしたいプラグインを 1 行ずつ列挙するテキストファイル

* **例**:

  ```text
  jorgebucaran/fisher
  oh-my-fish/theme-bobthefish
  jethrokuan/fish-autosuggestions
  PatrickF1/fish-syntax-highlighting
  oh-my-fish/plugin-git
  jethrokuan/fzf
  numtide/zi
  fish-docs/fish-abbreviation-tutorial
  ```

* **ポイント**:

  * プラグインを追加・削除する際は、このファイルを編集し、Fish を再起動または `fisher update` する。
  * 環境ごとに同じ `fishfile` を共有すれば、プラグイン構成を統一できる。

---

### その他のディレクトリ

* **completions/**

  * `.fish` 拡張子の補完スクリプトを配置。Fish 起動時に自動で読み込まれ、コマンド補完が拡張される。
  * 例: `completions/fisher.fish` を置くと `fisher` コマンドの補完が追加される。

* **conf.d/**

  * Fish が起動時に `source` するスクリプトをまとめる場所。たとえばエイリアスや環境設定などを個別ファイルとして管理。

* **fish\_plugins/**

  * 将来的にプラグイン関連の設定スクリプトや自作プラグインを配置する想定。

* **fish\_variables/**

  * `fish_user_variables.fish` 等を置き、Universal 変数（PATH追加、エイリアス定義など）を一元管理。

* **themes/**

  * プロンプトテーマやカラースキームを配置するディレクトリ。
  * 例: `themes/bobthefish.fish` を置き、`config.fish` から読み込むことでテーマを変更できる。

---

## Fisher を使ったプラグイン管理

1. **Fisher のインストール**  (※ `install_fisher.sh` で自動実行済み)

   ```fish
   curl -sL https://git.io/fisher | source
   fisher install jorgebucaran/fisher
   ```

2. **functions/fishfile にプラグインを列挙**

   ```text
   jorgebucaran/fisher
   oh-my-fish/theme-bobthefish
   jethrokuan/fish-autosuggestions
   PatrickF1/fish-syntax-highlighting
   oh-my-fish/plugin-git
   jethrokuan/fzf
   numtide/zi
   fish-docs/fish-abbreviation-tutorial
   ```

3. **Fish 起動時に自動同期**

   * `config.fish` 内に以下を記述すると、Fish を起動するたびに `fishfile` のプラグインがインストール・アップデートされる。

     ```fish
     if type -q fisher
       fisher install (cat $HOME/.config/fish/functions/fishfile)
     end
     ```
   * 重複や不要なプラグインがあれば `functions/fishfile` を修正して再起動する。

---

## 日常的な更新・メンテナンス方法

1. **リモートリポジトリの更新を pull**

   ```bash
   cd ~/dotfiles
   git pull origin main
   ```

   * 他マシンで設定を変更した場合は手元に最新を取り込む。

2. **Bootstrap スクリプトを再実行**

   ```bash
   cd ~/dotfiles
   bash bootstrap.sh
   ```

   * スクリプトを修正・追加した場合は再実行して適用。

3. **プラグインの追加・削除**

   * `config/dotfiles/fish/functions/fishfile` にプラグインを追加または削除。
   * Fish を再起動 (`exec fish`) または `fisher update` で反映。

4. **Fish 本体・Fisher のバージョン確認**

   ```fish
   fish --version
   fisher --version
   ```

   * 必要に応じて手動アップデート。

---

## トラブルシューティング

* **Fisher が動作しない**

  1. `install_fisher.sh` を単独で実行し、エラーを確認。
  2. Fish を再起動 (`exec fish`) したうえで `type -q fisher` を再チェック。

* **Fish がデフォルトシェルにならない / PAM 認証エラー**

  1. `install_fish.sh` が `sudo chsh -s $(which fish) $USER` を実行しているか確認。
  2. Orbstack や WSL 環境では、パスワード認証が無効な場合があるため `sudo chsh` を使う必要がある。

* **brew が PATH に反映されない**

  1. `install_homebrew.sh` が `~/.profile` に `eval "$(brew shellenv)"` を追記したか確認。
  2. ログアウト→再ログイン、もしくは `source ~/.profile` で反映。

* **プラグインの競合 / エラー**

  1. `functions/fishfile` 内に重複したプラグインがないか確認。
  2. `fisher remove <プラグイン名>` で一度アンインストールし、必要なものだけ再インストールする。

---

## その他の注意事項

* **macOS での利用**

  * `install_homebrew.sh` は Linuxbrew 向けなので、macOS では別途 Homebrew インストール手順を準備する必要があります。

* **WSL 環境での chsh 動作**

  * `chsh` がうまく動かない場合は、手動で Windows ターミナルのデフォルトシェルを Fish に設定してください。

* **プライベートリポジトリでバックアップ**

  * GitHub の公開リポジトリに加えて、プライベートミラーや自社サーバーにもバックアップを取っておくと安全です。

---

以上の手順で、**Fish シェルから Fisher まで** の環境構築を一気通貫で管理できます。将来的に Neovim や tmux、lazygit、mise などを追加したい場合は、`bootstrap/scripts/` に新しいスクリプトを追加し、`config/dotfiles/` に設定ディレクトリを増やすだけで拡張可能です。
