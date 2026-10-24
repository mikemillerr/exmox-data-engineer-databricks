with silver_counts as (
    select count(*) as rows from {{ source("silver", "events") }}
)
select "gold is empty while silver contains events" as failure_reason
from silver_counts s
where s.rows > 0
  and not exists (select 1 from {{ ref("daily_metrics") }})
