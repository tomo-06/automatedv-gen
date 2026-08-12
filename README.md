# automatedv-gen

Generate [AutomateDV](https://github.com/Datavault-UK/automate-dv) metadata (YAML) and dbt models from source table metadata.

> **Note**
> This is an unofficial, independent project and is not affiliated with, endorsed by, or supported by Datavault-UK.
> AutomateDV is a product of Business Thinking Ltd (trading as Datavault). Data Vault 2.0™ is a trademark of Empowered Holdings LLP.

## Status

Work in progress. Not yet usable.

## License

Apache-2.0


## Requirements

- WSL2 (Ubuntu) / Docker Desktop
- uv
- make

## Setup

```bash
uv sync
make up      # PostgreSQL を起動
make deps    # dbt パッケージを導入
make debug   # 接続確認
```

## Commands

| Command | Description |
|---|---|
| `make up` / `make down` | PostgreSQL の起動 / 停止 |
| `make deps` | dbt パッケージの導入 |
| `make debug` | dbt の接続確認 |
| `make build` | dbt の build 実行 |
| `make clean` | dbt の生成物削除 |
