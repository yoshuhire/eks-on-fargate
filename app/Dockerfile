# ベースイメージとしてPythonを使用
FROM python:3.9-slim

# 作業ディレクトリを作成
WORKDIR /app

# 必要なファイルをコンテナにコピー
COPY app.py /app

# 必要なパッケージをインストール
RUN pip install Flask

# 環境変数を設定（デフォルト値）
ENV ENV=LOCAL

# Flaskアプリをポート5000で起動
CMD ["python", "app.py"]

# コンテナの外部に公開するポート
EXPOSE 8081
