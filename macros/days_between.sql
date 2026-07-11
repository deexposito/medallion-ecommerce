{% macro days_between(start_date, end_date) %}
    date_diff('day', {{ start_date }}, {{ end_date }})
{% endmacro %}
