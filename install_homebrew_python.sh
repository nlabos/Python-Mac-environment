#!/bin/bash

# Detect current shell
detect_shell() {
    local shell_path
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    elif [ -n "$FISH_VERSION" ]; then
        echo "fish"
    else
        shell_path=$(echo "$SHELL" | xargs basename)
        if [ "$shell_path" = "zsh" ] || [ "$shell_path" = "bash" ] || [ "$shell_path" = "fish" ]; then
            echo "$shell_path"
        else
            echo "bash"  # Default to bash if detection fails
        fi
    fi
}

CURRENT_SHELL=$(detect_shell)
echo "検出されたシェル: $CURRENT_SHELL"

# Set config file based on shell
if [ "$CURRENT_SHELL" = "zsh" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ "$CURRENT_SHELL" = "bash" ]; then
    # On macOS, use .bash_profile for login shells
    SHELL_CONFIG="$HOME/.bash_profile"
elif [ "$CURRENT_SHELL" = "fish" ]; then
    SHELL_CONFIG="$HOME/.config/fish/config.fish"
    mkdir -p "$(dirname "$SHELL_CONFIG")"
fi

echo "使用する設定ファイル: $SHELL_CONFIG"

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "Homebrewがインストールされていません。インストールを開始します..."
    
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Determine Homebrew location based on architecture
    if [[ $(uname -m) == "arm64" ]]; then
        BREW_PATH="/opt/homebrew/bin/brew"
    else
        BREW_PATH="/usr/local/bin/brew"
    fi
    
    # Add Homebrew to PATH based on shell
    if [ "$CURRENT_SHELL" = "fish" ]; then
        echo "eval ($BREW_PATH shellenv)" >> "$SHELL_CONFIG"
        # For immediate effect, we need to use a different approach in a script
        eval "$($BREW_PATH shellenv)"
    else
        echo "eval \"\$(${BREW_PATH} shellenv)\"" >> "$SHELL_CONFIG"
        eval "$($BREW_PATH shellenv)"
    fi
    
    echo "Homebrewがインストールされ、PATHに追加されました。"
    echo "変更を適用するには、ターミナルを再起動するか、シェル設定ファイルをsourceしてください。"
else
    echo "Homebrewは既にインストールされています。"
fi

# Install Python 3.12.1 using Homebrew
if brew list python@3.12 &>/dev/null; then
    echo "Python 3.12は既にHomebrewによりインストールされています。"
else
    echo "Homebrew経由でPython 3.12.1をインストールしています..."
    brew install python@3.12
    
    # Make sure Python 3.12 is linked
    brew link python@3.12
    
    echo "Python 3.12.1がインストールされました。"
fi

# Verify Python installation
python_version=$(python3 --version)
echo "インストールされたPythonバージョン: $python_version"

# Check if we have Python 3.12.x
if [[ "$python_version" == *"3.12"* ]]; then
    echo "Python 3.12.xが利用可能です。"
else
    echo "警告: Python 3.12.xはデフォルトのPythonバージョンではありません。"
    
    # Find Python 3.12.x from Homebrew
    PYTHON312_PATH=$(brew --prefix)/bin/python3.12
    
    if [ -f "$PYTHON312_PATH" ]; then
        echo "Python 3.12は次の場所で利用可能です: $PYTHON312_PATH"
    else
        echo "エラー: Python 3.12実行ファイルが見つかりませんでした。"
    fi
fi