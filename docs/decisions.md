# 設計上の決定と背景

## コア層は DB 非依存に保つ
メタデータ変換ロジックは特定の DWH に依存しない純粋な Python として実装し、
接続とSQL方言の差異はアダプタ層に閉じる。
これにより、Postgres で開発して他プラットフォームで検証する際に
接続設定の差し替えだけで済み、テストも DB なしで実行できる。

## 開発環境に PostgreSQL を採用する
AutomateDV は v0.9.7 で Postgres を正式サポートしている。
無料であり、CI でもサービスコンテナとして起動できる。

### DuckDB を採用しない理由
軽量だが AutomateDV の公式サポート対象外。
マクロがプラットフォームごとに分岐しているため、動作の保証がない。

## バージョンは最新を追わない
AutomateDV の公式互換表を基準にする。

| 対象 | 固定 | 根拠 |
|---|---|---|
| Python | 3.12 | dbt-postgres での 3.13 サポートは dbt-core 1.10 以降 |
| dbt-core / dbt-postgres | 1.10.x | AutomateDV v0.11.4 の推奨。1.11 / 1.12 は未検証 |
| AutomateDV | 0.11.4 以上を明示ピン | https://automate-dv.readthedocs.io/en/latest/versions/ |

バージョンを上げる際は、必ず上記互換表を再確認する。

## 開発フロー
main を保護し、feature ブランチから PR 経由で squash merge する。
- ブランチ: `feat/` `fix/` `docs/` `chore/` `test/`
- コミット: Conventional Commits
- CI: PR ごとに Postgres コンテナを起動し `dbt build` と `pytest` を実行する

## テストデータ
公開データセット（jaffle_shop, TPC-H）は使用しない。
いずれも変更履歴を持たないため、Satellite の hashdiff による差分検知と
インクリメンタルロードの正しさを検証できない。
Faker で生成し、乱数シードを固定して再現性を確保する。

## ローカル開発環境（2026-08-12）

### dbt の実行場所：ホスト（WSL2）の uv 管理 venv。コンテナは PostgreSQL のみ

dbt をコンテナに入れると実行のたびにコンテナ越しになり、反復速度と
エディタの補完・デバッガの利便性が落ちる。また GitHub Actions では
`services:` で PostgreSQL を起動する構成になるため、
「DB のみコンテナ・dbt はホスト」がローカルと CI で同一構成になる。

トレードオフとして環境まるごとの再現性は下がるが、
`uv.lock` と `.python-version` の固定で実用上の差は小さいと判断した。

### PostgreSQL：16-alpine / ホスト側公開ポート 5433

5432 は Windows 側に PostgreSQL がインストールされている場合に競合するため、
ホスト側のみ 5433 にずらしている。コンテナ内は 5432 のまま。

データ領域は named volume（`pgdata`）を使用。
WSL2 でバインドマウントを使うと I/O 性能が落ち、権限エラーも起きやすい。

### dbt プロジェクトの位置：リポジトリ直下ではなく `dbt/`

Python パッケージと dbt プロジェクトが同居するため、直下は Python 側に譲る。
実行時は `--project-dir dbt --profiles-dir dbt` が必須になるので、
指定漏れを防ぐため Makefile にコマンドを集約している。

### profiles.yml：`~/.dbt/` ではなくリポジトリ内に配置

環境変数のデフォルト値を持たせてあり、`.env` が無くても動作する。
CI では `POSTGRES_PORT` 等を環境変数で上書きするだけで同じファイルを使える。

### AutomateDV：0.11.4 に完全固定し package-lock.yml をコミット

AutomateDV 0.11.4 の対応 dbt は `>=1.9.x, <3.0.0` だが、
推奨は「最新の dbt 1.10.x」。0.11.3 以前は 1.9.x 推奨のため、
dbt 1.10 系を使う場合は 0.11.4 以上が必要。
出典: https://automate-dv.readthedocs.io/en/latest/versions/

CI の安定を優先し、範囲指定ではなくバージョン完全固定とする。

### 認証情報の扱い

`.env.example` にはローカル使い捨て DB の初期値を実値で記載している。
コンテナ内にのみ存在し `docker compose down -v` で消えるため、
公開リポジトリに含めて問題ないと判断した。

Snowflake 対応を追加する時点でこの方針は変更する。
外部サービスの認証情報は `.env.example` に変数名のみを記載し、値は空とする。

### 検証結果（2026-08-12）

- dbt 1.10.22 / dbt-postgres 1.10.2 / AutomateDV 0.11.4
- `dbt debug` の Connection test: OK
- `dbt run`（モデル 0 本）: 正常終了、`Found 867 macros`
