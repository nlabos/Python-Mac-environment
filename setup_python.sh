#!/bin/bash

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

# .zprofileの設定
if [ -f "$HOME/.zprofile" ]; then
    if ! grep -q 'eval "$(pyenv init --path)"' "$HOME/.zprofile"; then
        echo -e '\n# pyenv設定' >> "$HOME/.zprofile"
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.zprofile"
        echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.zprofile"
        echo 'eval "$(pyenv init -)"' >> "$HOME/.zprofile"
        echo -e "${GREEN}pyenvのパス設定を.zprofileに追加しました${NC}"
    fi
else
    echo -e '\n# pyenv設定' > "$HOME/.zprofile"
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.zprofile"
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.zprofile"
    echo 'eval "$(pyenv init -)"' >> "$HOME/.zprofile"
    echo -e "${GREEN}.zprofileを作成し、pyenvの設定を追加しました${NC}"
fi

# .zshrcの設定
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q 'eval "$(pyenv init -)"' "$HOME/.zshrc"; then
        echo -e '\n# pyenv設定' >> "$HOME/.zshrc"
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.zshrc"
        echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.zshrc"
        echo 'eval "$(pyenv init -)"' >> "$HOME/.zshrc"
        echo -e "${GREEN}pyenvの初期化設定を.zshrcに追加しました${NC}"
    fi
else
    echo -e '\n# pyenv設定' > "$HOME/.zshrc"
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.zshrc"
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.zshrc"
    echo 'eval "$(pyenv init -)"' >> "$HOME/.zshrc"
    echo -e "${GREEN}.zshrcを作成し、pyenvの初期化設定を追加しました${NC}"
fi

# 設定ファイルを即時反映
echo "設定ファイルを読み込みます..."
source "$HOME/.zprofile"
source "$HOME/.zshrc"

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