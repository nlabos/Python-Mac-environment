#!/bin/bash

# Mac用Python環境セットアップスクリプト
# Homebrewを使用してPythonをインストールし、Pyenv環境を構築します

# ステータスメッセージ表示関数
print_status() {
    echo "===> $1"
}

# Homebrewがインストールされているか確認
if ! command -v brew &> /dev/null; then
    print_status "Homebrewがインストールされていません。Homebrewをインストールします..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 現在のセッションでHomebrewをPATHに追加
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon Mac
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"     # Intel Mac
    else
        print_status "エラー: Homebrewのインストールパスが見つかりません。"
        exit 1
    fi
else
    print_status "Homebrewは既にインストールされています。"
fi

# HomebrewでPythonをインストール
print_status "Homebrewを使用してPythonをインストールします..."
brew install python

# HomebrewでPyenvをインストール
print_status "Homebrewを使用してPyenvをインストールします..."
brew install pyenv

# Pyenv環境変数の設定
print_status "Pyenv環境変数を設定します..."

# シェルタイプの判定
SHELL_TYPE=$(basename "$SHELL")
SHELL_PROFILE=""

case "$SHELL_TYPE" in
    "bash")
        SHELL_PROFILE="$HOME/.bash_profile"
        if [[ ! -f "$SHELL_PROFILE" ]]; then
            SHELL_PROFILE="$HOME/.bashrc"
        fi
        ;;
    "zsh")
        SHELL_PROFILE="$HOME/.zshrc"
        ;;
    *)
        print_status "サポートされていないシェル: $SHELL_TYPE。手動でPyenv設定を追加してください。"
        exit 1
        ;;
esac

# 既にPyenvの初期化が設定されていない場合のみ追加
if ! grep -q "pyenv init" "$SHELL_PROFILE"; then
    print_status "Pyenvの初期化設定を $SHELL_PROFILE に追加します..."
    cat >> "$SHELL_PROFILE" << 'EOF'

# Pyenv設定
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
EOF
else
    print_status "Pyenvの初期化設定は既に $SHELL_PROFILE に存在します。"
fi

# 現在のセッションでPyenv有効化のためにシェルプロファイルを読み込み
print_status "シェルプロファイルを読み込みます..."
source "$SHELL_PROFILE"

# Pyenvで特定のPythonバージョンをインストール
PYTHON_VERSION="3.12.1"  # 必要に応じて変更可能
print_status "Pyenvを使用してPython $PYTHON_VERSION をインストールします..."
pyenv install $PYTHON_VERSION

# インストールしたバージョンをグローバルデフォルトに設定
print_status "Python $PYTHON_VERSION をグローバルデフォルトに設定します..."
pyenv global $PYTHON_VERSION
pyenv rehash

# Pythonインストールの確認
print_status "Pythonインストールを確認します..."
python --version

# テスト用にnumpyをインストール
print_status "テスト用にnumpyをインストールします..."
pip install numpy

# numpyインストールの確認
print_status "numpyインストールを確認します..."
python -c "import numpy; print(f'NumPyバージョン: {numpy.__version__}')"

if [ $? -eq 0 ]; then
    print_status "インストールが正常に完了しました！numpyが正しく動作しています。"
else
    print_status "エラー: numpyのインポートに失敗しました。インストールに問題があります。"
    exit 1
fi

print_status "PythonとPyenv環境のセットアップが完了しました！"