select day, country, platform
from {{ ref("daily_metrics") }}
group by day, country, platform
having count(*) > 1
