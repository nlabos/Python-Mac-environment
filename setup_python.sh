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
    brew install pyenv-virtualenv
fi

# macOS用の依存関係
echo "Pythonのビルドに必要な依存パッケージをインストールします..."
brew install openssl readline sqlite3 xz zlib tcl-tk

# 設定ファイルを上書きせずに新しい設定を追加する関数
append_if_not_exists() {
    local file="$1"
    local line="$2"
    
    # ファイルが存在しない場合は作成
    if [ ! -f "$file" ]; then
        echo "# 自動生成されたファイル - Python環境設定" > "$file"
        echo -e "${GREEN}$fileを新規作成しました${NC}"
    fi
    
    # 行が既に存在するか確認
    if ! grep -qF "$line" "$file"; then
        echo "$line" >> "$file"
        echo -e "${GREEN}設定を追加しました: $line${NC}"
    else
        echo -e "${YELLOW}設定は既に存在します: $line${NC}"
    fi
}

# プロファイルファイルの設定
echo -e "\n${GREEN}=== プロファイルファイルの更新 ===${NC}"

# .zprofileと.zshrcの設定を更新（zshの場合）
if [ "$CURRENT_SHELL" = "zsh" ]; then
    # 以前の設定があれば削除するのではなく、新しい設定を追加
    echo "zshの設定ファイルを更新しています..."
    
    # .zprofileに設定を追加
    append_if_not_exists "$PROFILE_FILE" ""
    append_if_not_exists "$PROFILE_FILE" "# pyenv設定"
    append_if_not_exists "$PROFILE_FILE" "export PYENV_ROOT=\"\$HOME/.pyenv\""
    append_if_not_exists "$PROFILE_FILE" "[[ -d \$PYENV_ROOT/bin ]] && export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    append_if_not_exists "$PROFILE_FILE" "eval \"\$(pyenv init --path)\""
    
    # .zshrcに設定を追加
    append_if_not_exists "$RC_FILE" ""
    append_if_not_exists "$RC_FILE" "# pyenv設定"
    append_if_not_exists "$RC_FILE" "export PYENV_ROOT=\"\$HOME/.pyenv\""
    append_if_not_exists "$RC_FILE" "[[ -d \$PYENV_ROOT/bin ]] && export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    append_if_not_exists "$RC_FILE" "eval \"\$(pyenv init -)\""
    append_if_not_exists "$RC_FILE" "eval \"\$(pyenv virtualenv-init -)\""
else
    # bashの場合の設定
    echo "bashの設定ファイルを更新しています..."
    
    # .bash_profileに設定を追加
    append_if_not_exists "$PROFILE_FILE" ""
    append_if_not_exists "$PROFILE_FILE" "# pyenv設定"
    append_if_not_exists "$PROFILE_FILE" "export PYENV_ROOT=\"\$HOME/.pyenv\""
    append_if_not_exists "$PROFILE_FILE" "export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    append_if_not_exists "$PROFILE_FILE" "eval \"\$(pyenv init --path)\""
    
    # .bashrcに設定を追加
    append_if_not_exists "$RC_FILE" ""
    append_if_not_exists "$RC_FILE" "# pyenv設定"
    append_if_not_exists "$RC_FILE" "export PYENV_ROOT=\"\$HOME/.pyenv\""
    append_if_not_exists "$RC_FILE" "export PATH=\"\$PYENV_ROOT/bin:\$PATH\""
    append_if_not_exists "$RC_FILE" "eval \"\$(pyenv init -)\""
    append_if_not_exists "$RC_FILE" "eval \"\$(pyenv virtualenv-init -)\""
fi

# 現在のシェルに必要な環境変数を設定（一時的に）
echo -e "\n${GREEN}=== 現在のシェルに環境変数を設定 ===${NC}"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# pyenvの動作確認
echo -e "\n${GREEN}=== pyenvの動作確認 ===${NC}"
if command -v pyenv &> /dev/null; then
    echo "pyenvのバージョン: $(pyenv --version)"
else
    echo -e "${RED}pyenvが見つかりません。PATH環境変数を確認してください。${NC}"
    echo "PYENV_ROOT: $PYENV_ROOT"
    echo "PATH: $PATH"
    echo -e "${YELLOW}新しいターミナルを開くか、以下のコマンドを実行してください:${NC}"
    echo "exec \$SHELL -l"
    exit 1
fi

# Python 3.12.1のインストール
echo -e "\n${GREEN}=== Python 3.12.1のインストール ===${NC}"
echo "Python 3.12.1をインストールします..."

if pyenv versions | grep -q 3.12.1; then
    echo "Python 3.12.1は既にインストールされています"
else
    pyenv install 3.12.1 || {
        echo -e "${RED}Python 3.12.1のインストールに失敗しました${NC}"
        echo "よくあるエラーの原因:"
        echo "1. Xcodeコマンドラインツールがインストールされていない"
        echo "2. 必要な依存関係が不足している"
        echo -e "${YELLOW}以下のコマンドを実行してみてください:${NC}"
        echo "xcode-select --install"
        echo "brew install openssl readline sqlite3 xz zlib tcl-tk"
        exit 1
    }
fi

# Python 3.12.1をグローバルに設定
echo "Python 3.12.1をグローバルバージョンとして設定します..."
pyenv global 3.12.1
pyenv shell 3.12.1

# インストール確認
echo -e "\n${GREEN}=== インストール確認 ===${NC}"
PYTHON_PATH="$(pyenv which python)"
PIP_PATH="$(pyenv which pip)"

echo "Pythonのパス: $PYTHON_PATH"
echo "pipのパス: $PIP_PATH"
echo "Pythonバージョン: $($PYTHON_PATH --version)"

# numpy のインストール
echo -e "\n${GREEN}=== numpyのインストール ===${NC}"
$PIP_PATH install --upgrade pip
$PIP_PATH install numpy

# numpyのインストール確認
echo "numpyの動作確認..."
$PYTHON_PATH -c "import numpy; print('numpyのバージョン:', numpy.__version__)" || {
    echo -e "${RED}numpyのインストールに失敗した可能性があります${NC}"
}

# セットアップ完了
echo -e "\n${GREEN}=== セットアップ完了 ===${NC}"
echo "Pythonバージョン: $($PYTHON_PATH --version)"
echo "pipバージョン: $($PIP_PATH --version | awk '{print $1, $2}')"
echo "pyenvバージョン: $(pyenv --version)"

# 重要な最終メッセージ
echo -e "\n${YELLOW}!!! 重要 - 設定を有効にするために !!!${NC}"
echo -e "${YELLOW}新しいターミナルを開くか、以下のコマンドを実行してください:${NC}"
echo -e "${GREEN}exec \$SHELL -l${NC}"
echo -e "${YELLOW}その後、以下のコマンドでpyenvが正しく動作することを確認してください:${NC}"
echo -e "${GREEN}pyenv version${NC}"