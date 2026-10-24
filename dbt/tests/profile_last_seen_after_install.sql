select p.user_id
from {{ ref("user_profile") }} p
inner join {{ ref("installs") }} i using (user_id)
where p.last_seen_ts < i.install_ts
