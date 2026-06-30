select * from [dbo].[df_orders]
drop table [dbo].[df_orders]
--find top 10 highest reveue generating products 
select  top 10 [Product Id],sum([sale price]) as tot_Price
from [dbo].[df_orders]
group by [Product Id]
order by  tot_Price desc

--find top 5 highest selling products in each region
with cte  as (
select  Region,[Product Id],sum([sale price]) as sales
from [dbo].[df_orders]
group by [Product Id],Region
)
select * from (
select *
,ROW_NUMBER() over (partition by Region order by sales desc) as rn   
from cte) A
where rn <= 5

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as (
select distinct  year([Order Date]) Years  
,MONTH([Order Date]) Months
,round(sum([sale price]),2) sales 
from [dbo].[df_orders]
group by year([Order Date]),MONTH([Order Date])
--order by Years,Months Desc
)
select Months
,sum(case when Years=2022 then sales else 0 end) as sales_2022 
,sum(case when Years=2023 then sales else 0 end) as sales_2023 
from cte 
group by Months 

--for each category which month had highest sales 
with cte as (
select [Category],FORMAT([Order Date],'yyyyMM') as order_year_months,
sum([sale price]) as sales
from [dbo].[df_orders]
group by [Category],FORMAT([Order Date],'yyyyMM')
--order by [Category],FORMAT([Order Date],'yyyyMM')
) 
select * from (
select *,
ROW_NUMBER() over(partition by category order by sales desc ) as rn 
from cte
) a 
where rn = 1 
--which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select [Sub Category],year([Order Date]) Years  
,MONTH([Order Date]) Months
,round(sum([sale price]),2) sales 
from [dbo].[df_orders]
group by [Sub Category],year([Order Date]),MONTH([Order Date])
--order by Years,Months Desc
)
, cte2 as (
select [Sub Category] 
,sum(case when Years=2022 then sales else 0 end) as sales_2022 
,sum(case when Years=2023 then sales else 0 end) as sales_2023 
from cte 
group by [Sub Category]
)
select  * ,round((sales_2023 - sales_2022) * 100 / sales_2022,2) as diff_sales    
from cte2