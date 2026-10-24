{% test is_valid(model, condition, column_name=None) %}

select *
from {{ model }}
where not coalesce({{ condition }}, false)

{% endtest %}
