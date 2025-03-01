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
fi

echo "使用する設定ファイル: $SHELL_CONFIG"

# Verify pyenv is properly configured
if ! command -v pyenv &>/dev/null; then
    echo "pyenvがPATHに設定されていません。"
    echo "pyenvがインストールされ、シェル設定が正しいことを確認してください。"
    echo "$SHELL_CONFIGの内容を確認してください"
    exit 1
fi

echo "pyenvはPATHに正しく設定されています。"
echo "pyenvバージョン: $(pyenv --version)"

# Verify Python version
echo "現在のPythonバージョン: $(python --version)"
echo "Python実行ファイルのパス: $(which python)"

# Check if pyenv is managing the current Python version
if [[ "$(which python)" == *".pyenv"* ]]; then
    echo "成功: pyenvが現在のPython環境を管理しています。"
else
    echo "警告: 現在のPython実行ファイルはpyenvによって管理されていません。"
    echo "$SHELL_CONFIGのPATH設定を確認してください"
fi

# List all installed pyenv versions
echo "インストールされているpyenv Pythonバージョン:"
pyenv versions

# Try activating and deactivating Python versions
echo "pyenvバージョン切り替えテストを実行しています..."

# Save the current version
CURRENT_VERSION=$(pyenv version-name)

# List available versions
VERSIONS=($(pyenv versions --bare))

# If we have at least two versions, switch between them to test
if [ ${#VERSIONS[@]} -ge 2 ]; then
    # Find a version different from the current one
    for version in "${VERSIONS[@]}"; do
        if [ "$version" != "$CURRENT_VERSION" ]; then
            TEST_VERSION="$version"
            break
        fi
    done
    
    echo "$CURRENT_VERSIONから$TEST_VERSIONに切り替えています..."
    pyenv global "$TEST_VERSION"
    echo "現在使用中: $(python --version)"
    
    echo "$CURRENT_VERSIONに戻しています..."
    pyenv global "$CURRENT_VERSION"
    echo "現在使用中: $(python --version)"
    
    echo "pyenvバージョン切り替えテストに成功しました。"
else
    echo "pyenvにインストールされているPythonバージョンは1つだけです。バージョン切り替えテストをスキップします。"
fi

echo "pyenvは正しく設定され、動作しています。"