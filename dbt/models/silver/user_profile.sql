{{ config(materialized="table") }}

select
    p.user_id,
    p.events_lifetime,
    p.last_seen_ts,
    p.revenue_30d_eur,
    p.is_payer
from {{ source("bronze", "user_profile") }} p
inner join {{ ref("installs") }} i using (user_id)
where p.user_id rlike "^u_[0-9]{6}$"
  and p.events_lifetime >= 1
  and p.last_seen_ts >= i.install_ts
  and p.revenue_30d_eur >= 0
  and p.is_payer is not null
  and (not p.is_payer or p.revenue_30d_eur > 0)
