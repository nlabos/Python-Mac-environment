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
        
        # Homebrewのパスを設定
        if [ "$CURRENT_SHELL" = "zsh" ]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$PROFILE_FILE"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$PROFILE_FILE"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "Homebrewのインストールをスキップします。セットアップを中断します。"
        exit 1
    fi
fi

# pyenvとpyenv-virtualenvのインストール
if ! command -v pyenv &> /dev/null; then
    echo "pyenvをインストールします..."
    brew install pyenv
    brew install pyenv-virtualenv
fi

# 必要なビルド依存関係をインストール
echo "Pythonのビルドに必要な依存パッケージをインストールします..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install openssl readline sqlite3 xz zlib tcl-tk
fi

# プロファイルファイルの設定
setup_profile_file() {
    local file="$1"
    if [ -f "$file" ]; then
        # 既存の設定を削除（重複を避けるため）
        sed -i.bak '/# pyenv設定/d' "$file" 2>/dev/null || true
        sed -i.bak '/PYENV_ROOT/d' "$file" 2>/dev/null || true
        sed -i.bak '/pyenv init/d' "$file" 2>/dev/null || true
        sed -i.bak '/pyenv virtualenv-init/d' "$file" 2>/dev/null || true
    fi
    
    # 新しい設定を追加
    echo -e '\n# pyenv設定' >> "$file"
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$file"
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$file"
    echo 'eval "$(pyenv init --path)"' >> "$file"
    echo 'eval "$(pyenv init -)"' >> "$file"
    echo 'eval "$(pyenv virtualenv-init -)"' >> "$file"
    echo -e "${GREEN}pyenvの設定を$fileに追加しました${NC}"
}

# 設定ファイルの更新
setup_profile_file "$PROFILE_FILE"
setup_profile_file "$RC_FILE"

# 現在のシェルでpyenvを使えるようにする
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# pyenvが正しく機能するか確認
if ! command -v pyenv &> /dev/null; then
    echo -e "${RED}警告: pyenvがPATHに正しく設定されていません。${NC}"
    echo "手動でシェルを再起動してから続行してください。"
    exit 1
fi

echo -e "${GREEN}pyenvが正しく設定されました。バージョン: $(pyenv --version)${NC}"

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

# pipの更新
echo "pipを最新バージョンに更新します..."
"$PIP_PATH" install --upgrade pip

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

echo -e "${YELLOW}注意: 完全な環境の適用のために、以下のコマンドを実行するかターミナルを再起動してください:${NC}"
echo -e "${YELLOW}exec \$SHELL -l${NC}"

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