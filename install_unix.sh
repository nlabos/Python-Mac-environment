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

    source $SHELL_CONFIG
else
    echo "Homebrewは既にインストールされています。"
fi

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

        echo "ちいかわ"
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

# Verify Pyenv installation
pyenv_version=$(pyenv --version)
echo "インストールされたPyenvバージョン: $pyenv_version"

if pyenv versions --bare | grep -E "^3\.12\."; then
    echo "Python 3.12.x が既にインストールされています"
else
    echo "Python 3.12.x をインストールします。"
    pyenv install 3.12
    
    if pyenv versions --bare | grep -E "^3\.12\."; then
        echo "Python 3.12.x がインストールされました"
    else
        echo "Python 3.12.x のインストールに失敗しました"
        exit 1
    fi
fi


pyenv global 3.12

source $SHELL_CONFIG

echo "Python 3.12 が有効になりました"

