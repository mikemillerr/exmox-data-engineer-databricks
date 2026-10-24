{{ config(materialized="table") }}

select
    offer_id,
    offer_category,
    payout_type,
    payout_eur
from {{ source("bronze", "offers") }}
where offer_id rlike "^of_[0-9]{4}$"
  and offer_category in ("casino", "casual", "puzzle", "rpg", "strategy")
  and payout_type in ("cpa", "cpe", "cpi")
  and payout_eur > 0
