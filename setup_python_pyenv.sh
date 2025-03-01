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

# Check if Python 3.12 is installed
if ! command -v python3.12 &>/dev/null; then
    echo "Python 3.12が見つかりません。最初のスクリプトを実行してインストールしてください。"
    exit 1
else
    python_version=$(python3.12 --version)
    echo "Python ${python_version}を検出しました"
fi

# Make Python 3.12 the default
echo "Python 3.12をデフォルトのPython環境として設定しています..."

if [ "$CURRENT_SHELL" = "fish" ]; then
    # For fish shell
    echo 'set -gx PATH "$(brew --prefix)/opt/python@3.12/bin" $PATH' >> "$SHELL_CONFIG"
else
    # For bash/zsh
    echo 'export PATH="$(brew --prefix)/opt/python@3.12/bin:$PATH"' >> "$SHELL_CONFIG"
    export PATH="$(brew --prefix)/opt/python@3.12/bin:$PATH"
fi

echo "Python 3.12がデフォルトのPython環境として設定されました。"

# Install pyenv
if ! command -v pyenv &>/dev/null; then
    echo "pyenvをインストールしています..."
    
    # Install pyenv through Homebrew
    brew install pyenv
    
    # Set up pyenv initialization based on shell
    if [ "$CURRENT_SHELL" = "fish" ]; then
        # For fish shell
        echo 'status --is-interactive; and pyenv init - | source' >> "$SHELL_CONFIG"
        echo 'status --is-interactive; and pyenv virtualenv-init - | source' >> "$SHELL_CONFIG"
    else
        # For bash/zsh
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$SHELL_CONFIG"
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$SHELL_CONFIG"
        echo 'eval "$(pyenv init --path)"' >> "$SHELL_CONFIG"
        echo 'eval "$(pyenv init -)"' >> "$SHELL_CONFIG"
        
        # Set environment variables for immediate use
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init --path)" 2>/dev/null || true
        eval "$(pyenv init -)" 2>/dev/null || true
    fi
    
    echo "pyenvがインストールされ、設定されました。"
    echo "変更を適用するには、ターミナルを再起動するか、シェル設定ファイルをsourceしてください。"
else
    echo "pyenvは既にインストールされています。"
fi

# Verify pyenv installation
echo "pyenvのインストールを確認しています..."
if command -v pyenv &>/dev/null; then
    pyenv --version
    echo "pyenvは使用可能な状態です。"
else
    echo "警告: 現在のセッションでpyenvが利用できません。"
    echo "ターミナルを再起動するか、シェル設定ファイルをsourceして再試行してください。"
fi