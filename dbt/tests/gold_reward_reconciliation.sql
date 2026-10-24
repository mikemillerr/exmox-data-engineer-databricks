with expected as (
    select
        count(*) as payouts,
        sum(o.payout_eur) as cost_eur
    from {{ source("silver", "events") }} e
    inner join {{ source("silver", "offers") }} o using (offer_id)
    where e.event_name = "reward_paid"
),
actual as (
    select
        sum(reward_payouts) as payouts,
        sum(reward_cost_eur) as cost_eur
    from {{ ref("daily_metrics") }}
)
select *
from expected e
inner join actual a on true
where a.payouts is null
   or a.cost_eur is null
   or e.payouts != a.payouts
   or e.cost_eur != a.cost_eur
