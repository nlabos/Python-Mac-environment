# Mac用Python環境セットアップスクリプト README

## 概要

このスクリプト群は、macOS上にPython開発環境を自動的にセットアップするためのものです。特にPython 3.12を使用する開発環境を、様々なmacOSシェル（bash、zsh、fish）に対応させて構築します。

## インストール方法

インストールは次のいずれかの方法で実行できます：

1. **ワンライナーコマンド（推奨）**：
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/nlabos/Python-Mac-environment/refs/heads/master/install_unix.sh)"
   ```

2. **install.commandファイルを実行**：
   - ダウンロードした`install.command`ファイルをダブルクリック
   - または、ターミナルで `sh path/to/install.command` を実行

## スクリプトの動作

スクリプトは以下の手順で環境をセットアップします：

1. **シェル検出**：
   - 現在のシェル（zsh、bash、fishのいずれか）を自動的に検出
   - 適切なシェル設定ファイル（`.zshrc`、`.bash_profile`、`.config/fish/config.fish`）を選択

2. **Homebrew（パッケージマネージャー）のセットアップ**：
   - Homebrewが存在しない場合、自動的にインストール
   - macOSのアーキテクチャ（Intel/Apple Silicon）に応じて適切なパスを設定
   - シェル設定ファイルにHomebrewのパスを追加

3. **pyenv（Pythonバージョン管理ツール）のセットアップ**：
   - Homebrewを使用してpyenvをインストール
   - シェル設定ファイルにpyenvの初期化コードを追加
   - 環境変数を適切に設定

4. **Python 3.12のインストールと設定**：
   - pyenvを使用してPython 3.12をインストール
   - Python 3.12をグローバルデフォルトバージョンとして設定

## 必要な要件

- macOS（Intel または Apple Silicon）
- 管理者権限（実行前に、sudo ls)などの強制実行コマンドを実行することで、生徒のPCに管理者権限があるかを確認してください
- インターネット接続(インターネットの環境次第では、インストールに時間がかかる可能性があります。)

## 注意事項

- スクリプト実行後、ターミナルの再起動またはシェル設定ファイルの再読み込みが必要な場合があります
- インストール中にパスワード入力を求められる場合があります（Homebrew関連）
- 既存の環境に影響を与える可能性があるため、重要なデータのバックアップを推奨します

## トラブルシューティング

スクリプト実行後にPythonが正しく認識されない場合：
1. ターミナルを再起動する
2. または以下のコマンドでシェル設定を再読み込み：
   - bash/zsh: `source ~/.bash_profile` または `source ~/.zshrc`
   - fish: `source ~/.config/fish/config.fish`
