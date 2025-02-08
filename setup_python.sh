#!/bin/bash

# カラー設定
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# シェルの検出
CURRENT_SHELL=$(basename "$SHELL")
echo "検出されたシェル: $CURRENT_SHELL"

# 設定ファイルの決定
if [ "$CURRENT_SHELL" = "zsh" ]; then
    PROFILE_FILE="$HOME/.zprofile"
    RC_FILE="$HOME/.zshrc"
else
    PROFILE_FILE="$HOME/.bash_profile"
    RC_FILE="$HOME/.bashrc"
fi

echo "使用する設定ファイル:"
echo "- プロファイル: $PROFILE_FILE"
echo "- RCファイル: $RC_FILE"

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

# プロファイルファイルの設定
if [ -f "$PROFILE_FILE" ]; then
    if ! grep -q 'eval "$(pyenv init -)"' "$PROFILE_FILE"; then
        echo -e '\n# pyenv設定' >> "$PROFILE_FILE"
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$PROFILE_FILE"
        if [ "$CURRENT_SHELL" = "zsh" ]; then
            echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> "$PROFILE_FILE"
        else
            echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$PROFILE_FILE"
        fi
        echo 'eval "$(pyenv init -)"' >> "$PROFILE_FILE"
        echo -e "${GREEN}pyenvのパス設定を$PROFILE_FILEに追加しました${NC}"
    fi
else
    echo -e '\n# pyenv設定' > "$PROFILE_FILE"
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$PROFILE_FILE"
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> "$PROFILE_FILE"
    else
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$PROFILE_FILE"
    fi
    echo 'eval "$(pyenv init -)"' >> "$PROFILE_FILE"
    echo -e "${GREEN}$PROFILE_FILEを作成し、pyenvの設定を追加しました${NC}"
fi

# RCファイルの設定
if [ -f "$RC_FILE" ]; then
    if ! grep -q 'eval "$(pyenv init -)"' "$RC_FILE"; then
        echo -e '\n# pyenv設定' >> "$RC_FILE"
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$RC_FILE"
        if [ "$CURRENT_SHELL" = "zsh" ]; then
            echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> "$RC_FILE"
        else
            echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$RC_FILE"
        fi
        echo 'eval "$(pyenv init -)"' >> "$RC_FILE"
        echo -e "${GREEN}pyenvの初期化設定を$RC_FILEに追加しました${NC}"
    fi
else
    echo -e '\n# pyenv設定' > "$RC_FILE"
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$RC_FILE"
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> "$RC_FILE"
    else
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$RC_FILE"
    fi
    echo 'eval "$(pyenv init -)"' >> "$RC_FILE"
    echo -e "${GREEN}$RC_FILEを作成し、pyenvの初期化設定を追加しました${NC}"
fi

# 設定ファイルを即時反映
echo "設定ファイルを読み込みます..."
source "$PROFILE_FILE"
source "$RC_FILE"

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

echo "現在のシェルに対してPython 3.12.1を有効にします..."
pyenv shell 3.12.1 || {
    echo -e "${RED}シェルへのPython 3.12.1の設定に失敗しました${NC}"
    exit 1
}

# 現在のpyenvのステータスを表示
echo -e "\n${GREEN}=== pyenv version ===${NC}"
pyenv version

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

# 環境の確認
echo -e "\n${GREEN}=== 環境の確認 ===${NC}"
echo "Python version: $("$PYTHON_PATH" --version)"
echo "pip version: $("$PIP_PATH" --version)"
echo "pyenv version: $(pyenv --version)"
echo "PYENV_ROOT: $PYENV_ROOT"
echo "PATH: $PATH"

echo -e "${YELLOW}注意: 完全な環境の適用のために、新しいターミナルを開くことをお勧めします。${NC}"

# 設定ファイルの内容を表示
echo -e "\n${GREEN}=== $PROFILE_FILEの内容 ===${NC}"
if [ -f "$PROFILE_FILE" ]; then
    cat "$PROFILE_FILE"
else
    echo "$PROFILE_FILEが存在しません"
fi

echo -e "\n${GREEN}=== $RC_FILEの内容 ===${NC}"
if [ -f "$RC_FILE" ]; then
    cat "$RC_FILE"
else
    echo "$RC_FILEが存在しません"
fi