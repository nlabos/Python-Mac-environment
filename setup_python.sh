#!/bin/bash

# 明示的にBashを使用
if [ -z "$BASH" ]; then
    exec bash "$0" "$@"
fi

# カラー設定
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "Python開発環境のセットアップを開始します..."

# Homebrewがインストールされているか確認
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrewがインストールされていません。${NC}"
    read -p "Homebrewをインストールしますか？ (y/n): " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrewのインストールをスキップします。セットアップを中断します。"
        exit 1
    fi
fi

# pyenvのインストール
if ! command -v pyenv &> /dev/null; then
    echo "pyenvをインストールします..."
    brew install pyenv
fi

# .bash_profileの設定
if [ -f "$HOME/.bash_profile" ]; then
    if ! grep -q 'eval "$(pyenv init -)"' "$HOME/.bash_profile"; then
        echo -e '\n# pyenv設定' >> "$HOME/.bash_profile"
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.bash_profile"
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.bash_profile"
        echo 'eval "$(pyenv init -)"' >> "$HOME/.bash_profile"
        echo -e "${GREEN}pyenvのパス設定を.bash_profileに追加しました${NC}"
    fi
else
    echo -e '\n# pyenv設定' > "$HOME/.bash_profile"
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.bash_profile"
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.bash_profile"
    echo 'eval "$(pyenv init -)"' >> "$HOME/.bash_profile"
    echo -e "${GREEN}.bash_profileを作成し、pyenvの設定を追加しました${NC}"
fi

# .bashrcの設定
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q 'eval "$(pyenv init -)"' "$HOME/.bashrc"; then
        echo -e '\n# pyenv設定' >> "$HOME/.bashrc"
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.bashrc"
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'eval "$(pyenv init -)"' >> "$HOME/.bashrc"
        echo -e "${GREEN}pyenvの初期化設定を.bashrcに追加しました${NC}"
    fi
else
    echo -e '\n# pyenv設定' > "$HOME/.bashrc"
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.bashrc"
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.bashrc"
    echo 'eval "$(pyenv init -)"' >> "$HOME/.bashrc"
    echo -e "${GREEN}.bashrcを作成し、pyenvの初期化設定を追加しました${NC}"
fi

# 設定ファイルを即時反映
echo "設定ファイルを読み込みます..."
source "$HOME/.bash_profile"
source "$HOME/.bashrc"

# 環境変数の設定を即時反映
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Python 3.12のインストールと設定
echo "Python 3.12.1をインストールします..."
pyenv install 3.12.1 || {
    echo -e "${RED}Python 3.12.1のインストールに失敗しました${NC}"
    exit 1
}

echo "Python 3.12.1をグローバルバージョンとして設定します..."
pyenv global 3.12.1

# Pythonとpipのパスを確認
PYTHON_PATH="$(pyenv which python)"
PIP_PATH="$(pyenv which pip)"

echo "Pythonのパス: $PYTHON_PATH"
echo "pipのパス: $PIP_PATH"

# numpyのインストール
echo "numpyをインストールします..."
"$PIP_PATH" install numpy

# numpyのインストール確認
"$PYTHON_PATH" -c "
import numpy
print('numpyのバージョン:', numpy.__version__)
" || {
    echo -e "${RED}警告: numpyのインストールに失敗した可能性があります${NC}"
    exit 1
}

echo -e "${GREEN}セットアップが完了しました！${NC}"
echo "現在のPythonバージョン:"
"$PYTHON_PATH" --version

echo -e "${YELLOW}注意: 完全な環境の適用のために、新しいターミナルを開くことをお勧めします。${NC}"

# 設定ファイルの内容を表示
echo -e "\n${GREEN}=== .bash_profileの内容 ===${NC}"
if [ -f "$HOME/.bash_profile" ]; then
    cat "$HOME/.bash_profile"
else
    echo ".bash_profileが存在しません"
fi

echo -e "\n${GREEN}=== .bashrcの内容 ===${NC}"
if [ -f "$HOME/.bashrc" ]; then
    cat "$HOME/.bashrc"
else
    echo ".bashrcが存在しません"
fi