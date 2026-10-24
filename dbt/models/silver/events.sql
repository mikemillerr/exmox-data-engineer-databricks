{{ config(
    materialized="incremental",
    incremental_strategy="merge",
    unique_key="event_id"
) }}

with incoming as (
    select *
    from {{ source("bronze", "events") }}
    {% if is_incremental() %}
    where _loaded_at >= (select max(_loaded_at) from {{ this }})
    {% endif %}
),

deduplicated as (
    select
        *,
        row_number() over (
            partition by event_id
            order by ingest_ts, _loaded_at, _source_file
        ) as event_version
    from incoming
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
