# -----------------------------------------------------------------------------
# config.fish
# 主にプロンプト、zoxide、ghq、eza、および共通のエイリアスや環境変数を定義
# -----------------------------------------------------------------------------

# ──────────────────────────────────────────────────────────
# Homebrew (Linuxbrew) のパスを Fish で通す
# これがないと、~/.profile に追記していても Fish は読み込まないため 'brew' が使えない
if test -f /home/linuxbrew/.linuxbrew/bin/brew
    # brew shellenv を eval して PATH・環境変数を設定
    eval ("/home/linuxbrew/.linuxbrew/bin/brew" shellenv)
end
# ──────────────────────────────────────────────────────────

# 1. インタラクティブシェル時のみ設定を適用
if status --is-interactive
    # 1.1 Fisher プラグインの読み込み (functions ディレクトリから自動で読み込まれる)
    #      'fisher install' 実行済みであれば、各プラグインの関数や補完は
    #      ~/.config/fish/functions および ~/.config/fish/completions に配置済み

    # 1.2 Tide プロンプト設定
    #      初回のみ以下を実行し、インタラクティブにオプション決定可
    tide configure --quiet                            # Tide の初期設定を行う（同期・要一度）【 [oai_citation:24‡wiki.archlinux.org](https://wiki.archlinux.org/title/Fish?utm_source=chatgpt.com)】
    function fish_prompt
        tide prompt                                    # Tide を現在のプロンプトとして適用【 [oai_citation:25‡wiki.archlinux.org](https://wiki.archlinux.org/title/Fish?utm_source=chatgpt.com)】
    end

    # 1.3 zoxide 初期化
    #      zoxide.fish プラグインをインストール済みの場合は、
    #      以下でエイリアスやフックが有効化される（AOT 初期化）
    #      (他の方法： 'zoxide init fish | source' でも可だが、AOT 版を推奨)
    if type -q zoxide
        # zoxide 用エイリアス prefix を変更する場合は以下の変数を set 可能
        # 例: set --universal zoxide_cmd j   (z → j, zi → ji に変更)
        #set --universal zoxide_cmd j       # デフォルトは 'z'
        # フック方法を変更する場合:
        #set --universal zoxide_hook ''()
        set --universal zoxide_hook --on-variable PWD  # デフォルト: PWD（ディレクトリ移動時にスコア更新）【 [oai_citation:26‡github.com](https://github.com/kidonng/zoxide.fish?utm_source=chatgpt.com)】
        # 上記設定は zoxide.fish 公式リポジトリを参照（https://github.com/kidonng/zoxide.fish）【 [oai_citation:27‡github.com](https://github.com/kidonng/zoxide.fish?utm_source=chatgpt.com)】
        # 実際に初期化するには以下を実行
        zoxide init fish | source
    end

    # 1.4 ghq 初期化 (decors/fish-ghq プラグイン導入済みの場合)
    #      ghq 用キーバインド (Ctrl+g でリポジトリ一覧) を有効化
    #      デフォルトセレクタは fzf
    set -g GHQ_SELECTOR fzf                           # ghq で使用するセレクタを fzf に指定【 [oai_citation:28‡github.com](https://github.com/decors/fish-ghq?utm_source=chatgpt.com)】
    # 必要に応じてオプションを追加
    # set -g GHQ_SELECTOR_OPTS "--no-sort --reverse --ansi"
    # ghq プラグイン自体を有効化するには上記 fisher install のみで OK

    # 1.5 fzf.fish キーバインド設定 (Ctrl+R でコマンド履歴検索)
    if type -q fzf
        bind \cr fzf-history-widget                   # Enter 押下で fzf 履歴検索（任意で変更可）【 [oai_citation:29‡github.com](https://github.com/ajeetdsouza/zoxide?utm_source=chatgpt.com)】
    end

    # 1.6 eza エイリアス定義 (givensuman/fish-eza プラグイン利用)
    #      もし PLUGIN を使わず自前で alias 定義する場合は以下を参考にしてください
    #      例: alias ls='eza --git --icons --group --group-directories-first --time-style=long-iso --color-scale=all'
    if type -q eza
        # fish-eza プラグインを使う場合、環境変数で eza のデフォルトオプションを設定可
        set -g eza_params "--git --icons --group --group-directories-first --time-style=long-iso --color-scale=all"
        # cd したときに自動的にディレクトリ内容を表示したい場合
        # set -gx eza_run_on_cd true
        # fish-eza インストール済みなら、プラグイン側で自動的に alias が定義される
        # 手動でエイリアスを設定したい場合:
        # alias ll='eza --all --header --long $eza_params'
        # alias la='eza --all --binary $eza_params'
        # alias tree='eza --tree $eza_params'
    end

    # 1.7 nvm.fish （Node.js バージョン管理）初期化
    if type -q nvm
        # nvm をマウントしてくれる関数を有効
        # fish 用 nvm プラグインは自動で PATH を設定し、nvm コマンドを読み込む
        # 以下はプラグインがデフォルトで実行するため、明示的な source は不要
        # もし手動で初期化する場合:
        # nvm use default
    end

    # 1.8 done（長時間処理完了通知）設定例
    #      例えば `done sleep 60` のように使うと、
    #      タイマー終了時に通知が表示される

end

# 2. Greeting 表示を無効化
set -g fish_greeting ""                                 # 起動時の Welcome メッセージを非表示にする【 [oai_citation:30‡wiki.archlinux.org](https://wiki.archlinux.org/title/Fish?utm_source=chatgpt.com)】

# 3. PATH 設定（必要に応じて追加）  
#    既に eza, ghq, zoxide が brew 経由でインストールされているなら、
#    brew の bin ディレクトリを PATH に含めておく
if test -d "/usr/local/bin"
    set -gx PATH /usr/local/bin $PATH
end
if test -d "/opt/homebrew/bin"
    set -gx PATH /opt/homebrew/bin $PATH
end

# 4. 共通エイリアス
alias ll="ls -lAh"                                      # 互換性のため最低限定義
alias la="ls -A"
alias l="ls -CF"
alias g="git"

# 5. 必要に応じて環境変数やエクスポート設定
#    例: Go の PATH や Python virtualenv
# set -gx GOPATH $HOME/go
# set -gx PYENV_ROOT $HOME/.pyenv

# 6. OS 判定による分岐（Linux / macOS）
switch (uname)
    case Linux
        # Linux 固有の設定があればここに書く
        # 例: ディストリビューション固有の環境変数
    case Darwin
        # macOS 固有の設定があればここに書く
        # 例: バックスラッシュのエイリアス
        # alias pbcopy="reattach-to-user-namespace pbcopy"
end