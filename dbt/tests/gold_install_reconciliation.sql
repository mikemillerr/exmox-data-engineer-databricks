with expected as (
    select count(*) as value from {{ source("silver", "installs") }}
),
actual as (
    select sum(installs) as value from {{ ref("daily_metrics") }}
)
select *
from expected e
inner join actual a on true
where e.value != a.value
