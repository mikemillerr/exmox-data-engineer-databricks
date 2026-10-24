{{ config(materialized="table") }}

select
    user_id,
    install_ts,
    country,
    platform,
    media_source,
    device_model,
    campaign_id,
    _loaded_at
from {{ source("bronze", "installs") }}
where user_id rlike "^u_[0-9]{6}$"
  and install_ts is not null
  and country in ("BR", "DE", "FR", "GB", "IN", "PL", "TR", "US")
  and platform in ("android", "ios")
  and media_source in ("applovin", "meta", "tiktok", "unity", "organic")
  and (
      (media_source = "organic" and campaign_id is null)
      or (media_source != "organic" and campaign_id rlike "^cmp_[0-9]{3}$")
  )
