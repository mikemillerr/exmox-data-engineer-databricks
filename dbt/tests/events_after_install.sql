select e.event_id
from {{ ref("events") }} e
inner join {{ ref("installs") }} i using (user_id)
where e.event_ts < i.install_ts
