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
