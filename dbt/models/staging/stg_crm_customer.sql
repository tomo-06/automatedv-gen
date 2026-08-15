{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: crm_customer
derived_columns:
    CUSTOMER_BK: lpad(regexp_replace(customer_id, '[^0-9]', '', 'g'), 4, '0')
    LOAD_DATETIME: crm_ingested_at
    RECORD_SOURCE: "!crm_customer"
hashed_columns:
    CUSTOMER_HK: CUSTOMER_BK
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}
