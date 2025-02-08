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
    
    # .zshrcの設定
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'eval "$(pyenv init --path)"' "$HOME/.zshrc"; then
            echo -e '\n# pyenv設定' >> "$HOME/.zshrc"
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.zshrc"
            echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.zshrc"
            echo 'eval "$(pyenv init --path)"' >> "$HOME/.zshrc"
            echo 'eval "$(pyenv init -)"' >> "$HOME/.zshrc"
            
            echo -e "${GREEN}pyenvのパス設定を.zshrcに追加しました${NC}"
            source "$HOME/.zshrc"
        fi
    else
        echo -e "${YELLOW}.zshrcファイルが見つかりません。手動で設定を追加してください。${NC}"
    fi
else
    echo -e "${GREEN}pyenvは既にインストールされています${NC}"
fi

# Python 3.12のインストールと設定
echo "Python 3.12をインストールします..."
pyenv install 3.12 || {
    echo -e "${RED}Python 3.12のインストールに失敗しました${NC}"
    exit 1
}

echo "Python 3.12をグローバルバージョンとして設定します..."
pyenv global 3.12

# numpyのインストール
echo "numpyをインストールします..."
pip install numpy

# numpyのインストール確認
python3 -c "
import numpy
print('numpyのバージョン:', numpy.__version__)
" || {
    echo -e "${RED}警告: numpyのインストールに失敗した可能性があります${NC}"
    exit 1
}

echo -e "${GREEN}セットアップが完了しました！${NC}"
echo "現在のPythonバージョン:"
python --version
