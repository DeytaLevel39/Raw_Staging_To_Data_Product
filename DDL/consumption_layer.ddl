create schema if not exists consumption_layer;

create or replace view consumption_layer.v_customers_as_is as
select customer_hk, customer_id, customer_number, first_name, last_name, lastmodifieddate, createddate, effective_from,
load_date
from
(select h.customer_hk, h.customer_number, s.crud_flag, s.customer_id, s.first_name, s.last_name, s.lastmodifieddate, s.createddate, s.effective_from, s.load_date,row_number() over(partition by s.customer_hk order by s.lastmodifieddate desc) as rn
from data_vault.hub_customer h, data_vault.sat_customer s
where s.customer_hk = h.customer_hk)
where rn = 1 and crud_flag <> 'D';

create or replace view consumption_layer.v_orders_as_is as
select order_hk, customer_hk, order_id, order_number, order_price, lastmodifieddate, createddate, effective_from, load_date
from (select h.order_hk, h.order_number, co.customer_hk, s.order_id, s.order_price, s.lastmodifieddate, s.createddate, s.effective_from, s.load_date,
s.crud_flag, row_number() over(partition by s.order_hk order by s.lastmodifieddate desc) as rn
from data_vault.hub_order h, data_vault.sat_order s, data_vault.link_order_customer co
where s.order_hk = h.order_hk
  and co.order_hk = h.order_hk)
where rn = 1 and crud_flag <> 'D';

create or replace view consumption_layer.v_customer_orders_as_is as
select customer_number, first_name, last_name, order_number, order_price, o.createddate,
o.lastmodifieddate
from consumption_layer.v_customers_as_is c, consumption_layer.v_orders_as_is o
where o.customer_hk = c.customer_hk;

create or replace view consumption_layer.v_customer_history as
select h.customer_hk, h.customer_number, s.customer_id, s.first_name, s.last_name,
s.lastmodifieddate, s.createddate, s.effective_from, s.crud_flag, s.load_date
from data_vault.hub_customer h, data_vault.sat_customer s
where s.customer_hk = h.customer_hk;