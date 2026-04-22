
/* SuperStore SQL Analysis Project */

CREATE TABLE superstore_raw 
( 
ship_mode TEXT, 
segment TEXT, 
country TEXT, 
city TEXT, 
state TEXT, 
postal_code TEXT,
region TEXT, 
category TEXT, 
sub_category TEXT, 
sales NUMERIC, 
profit NUMERIC, 
quantity INT, 
discount NUMERIC 
);

select * from superstore_raw 
limit 20;
----------------------------------------------------------------
-- Sales by Region 
select 
region,
round(sum(sales),2) as sales
from superstore_raw 
group by region
order by sales;

---------------------------------------------------------------
--Profit by Region 
-- checking high sales means high profit

select 
region,
round(sum(profit),2) as profit
from  superstore_raw 
group by region
order by profit;
--------------------------------------------------------------
-- Profit margin by Category
-- This tell which category is making more money

select 
category, 
round(sum(profit),2) as profit
from superstore_raw 
group by category
order by profit desc;

----------------------------------------------------------------
-- Discount impact on profit
-- trying to see if giving discount is hurting business

select 
discount,  
round(sum(profit),2) as profit
from superstore_raw 
group by discount 
order by profit;
-----------------------------------------------------------
-- Loss making sub categories
-- which products are losing money

select
sub_category, 
            sum(profit ) as profit
            from superstore_raw 
            group by sub_category 
            having sum(profit)  < 0
            order by profit;

-------------------------------------------------------------

/* Top Cities by Sales */

select 
            city, round(sum(sales),2) as sales
 from 
             superstore_raw 
            group by city 
            order by  sales desc;
--------------------------------------------------------------

-- Ranking sub categories by profit  within each region

   select 
            region ,
            sub_category, 
             sum(profit)as profit , 
             rank()over(partition by region order by sum(profit ) desc) as rank_in_region
             from superstore_raw
             group by region,sub_category
            

--------------------------------------------------------------

/* Top 3 profitable sub-categories in each region */

with cte as (
            select 
            region ,
            sub_category, 
             sum(profit)as profit , 
             rank()over(partition by region order by sum(profit ) desc) as rank_in_region
             from superstore_raw
             group by region,sub_category)
             
select * from cte 
where rank_in_region <=3;
            
--------------------------------------------------------------
/* Profitability vs Discount */

select 
    case
            when discount = 0 then 'No Discount'
            when discount <= 0.2 then  'Low'
            when discount <= 0.5 then 'Medium'
            else 'High'
        end as  discount_level,
        round(sum(sales),2)as  total_sales,
        round(sum(profit),2) as total_profit
    from  superstore_raw
group by discount_level
order by total_profit desc;

----------------------------------------------------------------
/* Identifying under performing Regions */

with region_summary as 
(
select
region , 
round(sum(sales),2) as total_sales ,
round(sum(profit),2)  as total_profit
from superstore_raw
group by region 
)
select *, 
round(total_profit / nullif (total_sales,0), 2) as profit_margin
from region_summary
order by profit_margin;

------------------------------------------------------------
/* Top vs Bottom products */

with product_pref as
(
select 
sub_category , 
round(sum(profit),2) as total_profit
from superstore_raw 
group by sub_category 
)
select 
sub_category,
total_profit,
case 
	when total_profit < 0 then 'Loss'
        else 'Profitable'
        end as status
        from product_pref
        order by total_profit;
        
-------------------------------------------------------------
/* Total contribution according to sub category */

select 
    category,
    sum(sales) as total_sales,
    round(100.0 * sum(sales) / sum(sum(sales)) over (), 2) as contribution_pct
from superstore_raw
group by category;

   or
   
with cte as 
(
select 
category,
sum(sales) as total_sales
from superstore_raw
group by category
)
select *, round(total_sales/sum(total_sales)over() *100.0,2) as contribution_part
from cte

-----------------------------------------------------------------
/* High sales but Low profit */

select 
sub_category , 
round(sum(sales),0) as total_sales,
round(sum(profit),2) as total_profit
from superstore_raw 
group by sub_category
having  round(sum(sales),0) >50000 and round(sum(profit),2) <5000;

