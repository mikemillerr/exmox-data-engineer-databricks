{{ config(
    materialized="incremental",
    incremental_strategy="merge",
    unique_key=["day", "country", "platform"]
) }}

with source_rows as (
    select
        date(install_ts) as day,
        country,
        platform,
        _loaded_at as source_loaded_at
    from {{ source("silver", "installs") }}

    union all

    select
        date(e.event_ts) as day,
        i.country,
        i.platform,
        e._loaded_at as source_loaded_at
    from {{ source("silver", "events") }} e
    inner join {{ source("silver", "installs") }} i using (user_id)
),

affected_keys as (
    select day, country, platform
    from source_rows
    {% if is_incremental() or var("gold_date", none) %}
    where 1 = 1
      {% if is_incremental() and not var("gold_date", none) %}
      and source_loaded_at >= coalesce(
          (select max(source_watermark) from {{ this }}),
          timestamp "1900-01-01 00:00:00"
      )
      {% endif %}
      {% if var("gold_date", none) %}
      and day = date '{{ var("gold_date") }}'
      {% endif %}
    {% endif %}
    group by day, country, platform
),

install_metrics as (
    select
        date(i.install_ts) as day,
        i.country,
        i.platform,
        count(distinct i.user_id) as installs,
        max(i._loaded_at) as install_watermark
    from {{ source("silver", "installs") }} i
    inner join affected_keys a
        on date(i.install_ts) = a.day
       and i.country = a.country
       and i.platform = a.platform
    group by date(i.install_ts), i.country, i.platform
),

event_metrics as (
    select
        date(e.event_ts) as day,
        i.country,
        i.platform,
        count(distinct case when e.event_name = "app_open" then e.user_id end) as app_open_users,
        count(distinct case when e.event_name = "offer_view" then e.user_id end) as offer_view_users,
        count(distinct case when e.event_name = "offer_start" then e.user_id end) as offer_start_users,
        count(distinct case when e.event_name = "goal_reached" then e.user_id end) as goal_reached_users,
        count(distinct case when e.event_name = "reward_paid" then e.user_id end) as reward_paid_users,
        count(distinct case when e.event_name = "reward_paid" then e.event_id end) as reward_payouts,
        sum(case when e.event_name = "reward_paid" then o.payout_eur else 0 end) as reward_cost_eur,
        max(e._loaded_at) as event_watermark
    from {{ source("silver", "events") }} e
    inner join {{ source("silver", "installs") }} i using (user_id)
    inner join {{ source("silver", "offers") }} o using (offer_id)
    inner join affected_keys a
        on date(e.event_ts) = a.day
       and i.country = a.country
       and i.platform = a.platform
    group by date(e.event_ts), i.country, i.platform
)

select
    coalesce(i.day, e.day) as day,
    coalesce(i.country, e.country) as country,
    coalesce(i.platform, e.platform) as platform,
    coalesce(i.installs, 0) as installs,
    coalesce(e.app_open_users, 0) as app_open_users,
    coalesce(e.offer_view_users, 0) as offer_view_users,
    coalesce(e.offer_start_users, 0) as offer_start_users,
    coalesce(e.goal_reached_users, 0) as goal_reached_users,
    coalesce(e.reward_paid_users, 0) as reward_paid_users,
    coalesce(e.reward_payouts, 0) as reward_payouts,
    coalesce(e.reward_cost_eur, 0) as reward_cost_eur,
    greatest(
        coalesce(i.install_watermark, timestamp "1900-01-01 00:00:00"),
        coalesce(e.event_watermark, timestamp "1900-01-01 00:00:00")
    ) as source_watermark
from install_metrics i
full outer join event_metrics e
    on i.day = e.day
   and i.country = e.country
   and i.platform = e.platform
