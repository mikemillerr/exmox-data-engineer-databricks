{{ config(
    materialized="incremental",
    incremental_strategy="merge",
    unique_key="event_id"
) }}

with incoming as (
    select *
    from {{ source("bronze", "events") }}
    {% if is_incremental() %}
    where _loaded_at >= coalesce(
        (select max(_loaded_at) from {{ this }}),
        timestamp "1900-01-01 00:00:00"
    )
    {% endif %}
),

candidates as (
    select
        user_id,
        event_ts,
        event_name,
        offer_id,
        event_id,
        ingest_ts,
        _loaded_at,
        _source_file
    from incoming
    {% if is_incremental() %}
    union all
    select
        user_id,
        event_ts,
        event_name,
        offer_id,
        event_id,
        ingest_ts,
        _loaded_at,
        null as _source_file
    from {{ this }}
    where event_id in (select event_id from incoming)
    {% endif %}
),

deduplicated as (
    select
        *,
        row_number() over (
            partition by event_id
            order by ingest_ts, _loaded_at, _source_file
        ) as event_version
    from candidates
)

select
    e.user_id,
    e.event_ts,
    e.event_name,
    e.offer_id,
    e.event_id,
    e.ingest_ts,
    e._loaded_at
from deduplicated e
inner join {{ ref("installs") }} i using (user_id)
inner join {{ ref("offers") }} o using (offer_id)
where e.event_version = 1
  and e.user_id rlike "^u_[0-9]{6}$"
  and e.event_ts is not null
  and e.ingest_ts is not null
  and e.event_name in ("app_open", "offer_view", "offer_start", "goal_reached", "reward_paid")
  and e.ingest_ts >= e.event_ts
  and e.event_ts >= i.install_ts
