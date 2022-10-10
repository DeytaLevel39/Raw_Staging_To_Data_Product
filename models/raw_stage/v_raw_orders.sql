select distinct
o.ORDER_ID,
o.ORDER_NUMBER,
o.ORDER_PRICE,
o.LASTMODIFIEDDATE,
o.CREATEDDATE,
o.CRUD_FLAG,
c.CUSTOMER_NUMBER
from
    {{ source('dbtvault_bigquery_demo', 'repl_orders') }} as o
left join
    {{ source('dbtvault_bigquery_demo', 'repl_customers') }} as c on c.customer_id = o.customer_id