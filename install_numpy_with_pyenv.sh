#!/bin/bash

# Check if pyenv is available
if ! command -v pyenv &>/dev/null; then
    echo "pyenvが利用できません。2番目のスクリプトを実行してから、ターミナルを再起動してください。"
    exit 1
fi

echo "pyenvを使用してPython 3.12.1をインストールしています..."

# Install Python 3.12.1 using pyenv
if ! pyenv versions | grep -q 3.12.1; then
    pyenv install 3.12.1
else
    echo "Python 3.12.1は既にpyenvによってインストールされています。"
fi

# Set Python 3.12.1 as the global version
pyenv global 3.12.1
echo "Python 3.12.1がpyenvのグローバルバージョンとして設定されました。"

# Verify the Python version
echo "現在のPythonバージョン: $(python --version)"

# Ensure pip is up to date
echo "pipを更新しています..."
python -m pip install --upgrade pip

# Install numpy
echo "numpyをインストールしています..."
python -m pip install numpy

# Verify numpy installation
echo "numpyのインストールを確認しています..."
if python -c "import numpy; print(f'numpy {numpy.__version__} がインストールされました')" 2>/dev/null; then
    echo "numpyはpyenv Python 3.12.1環境に正常にインストールされました。"
else
    echo "エラー: numpyのインポートに失敗しました。インストールが失敗した可能性があります。"
    exit 1
fi