/****** Script for SelectTopNRows command from SSMS  ******/
------------- ANALYTIXLABS INSTITUTE, BENGALURU ---------------
select * from Customer
select * from transactions
select * from prod_cat_info

--Q1.
select COUNT(*)
from customer
union all 
select COUNT(*)
from prod_cat_info
union all
select COUNT(*)
from transactions

--Q2.
select count(Qty)
   from Transactions
   where Qty < 0

--Q3.
select tran_date, CONVERT(varchar,tran_date, 23) as formatdate
from Transactions

--Q4.
select MAX(tran_date) [LastDate], min(tran_date) [FirstDate],
    DATEDIFF(day, min(tran_date), max(tran_date)) [Days],
    DATEDIFF(MONTH, Min(tran_date), Max(tran_date)) [Monnth],
    DATEDIFF(year, Min(tran_date), max(tran_date)) [year]
from Transactions

--Q5.
select * 
from prod_cat_info
where prod_subcat = 'DIY'

----------------------------------------------------
--Data Analysis
--Q1
select top 1 store_type, count(transaction_id) [count]
from Transactions
group by store_type
order by count(transaction_id) desc

--Q2
select Gender,
	COUNT(case when gender = 'M' then 1 else 0 end)[Males],
	COUNT(case when gender = 'F' then 1 else 0 end)[Females]
from Customer
group by Gender
 
--Q3

select top 1 city_code, count(customer_Id) [count]
from Customer
group by city_code
order by count(customer_id) desc

 --Q4
 select distinct COUNT(prod_subcat) from prod_cat_info
 where prod_cat = 'Books'

 --Q5
 select MAX(Qty) as [max quantity]
 from Transactions

 -- select MAX(t.qty) 
 -- from prod_cat_info pci inner join Transactions t on pci.prod_cat_code=t.prod_cat_code and pci.prod_sub_cat_code=t.prod_subcat_code


 --Q6
 select t.Store_type, SUM(total_amt)[net revenue]
	from prod_cat_info pci inner join Transactions t on pci.prod_cat_code = t.prod_cat_code and pci.prod_sub_cat_code = t.prod_subcat_code 
	where prod_cat = 'Electronics' or prod_cat = 'Books'
 group by Store_type

 --Q7
 select cust_id, COUNT(cust_id)[count of custid]
	from Transactions
	where Qty >= 0
group by cust_id
	having COUNT(cust_id) > 10

 --Q8
 select t.prod_cat_code, sum(t.total_amt) [Revenue]
	from Transactions t left join prod_cat_info pci on t.prod_cat_code=pci.prod_cat_code and t.prod_subcat_code=pci.prod_sub_cat_code
	where t.Store_type = 'flagship store' and (t.prod_cat_code = 1 or t.prod_cat_code = 3)
	group by t.prod_cat_code

--Q9
select  pci.prod_subcat, c.gender, sum(t.total_amt)[Revenue]
	from Customer c inner join Transactions t on c.customer_Id=t.cust_id
	inner join prod_cat_info pci on t.prod_cat_code=pci.prod_cat_code and t.prod_subcat_code=pci.prod_sub_cat_code
	where c.Gender = 'M' and pci.prod_cat_code = 3
	group by pci.prod_subcat, c.gender


--Q10
select top 5 p.prod_subcat[Sub category],
	ROUND(SUM(cast(case when t.Qty > 0 then t.Qty else 0 end as float)),2) as [Sales],
	ROUND(SUM(CAST(case when t.Qty < 0 then t.Qty else 0 end as float)),2) as [returns],
	ROUND(sum(cast(case when t.Qty > 0 then t.Qty else 0 end as float)),2)
		- ROUND(SUM(CAST(case when t.Qty < 0 then t.total_amt else 0 end as float)),2) as [profit],
	
	((ROUND(SUM(cast(case when t.Qty > 0 then t.Qty else 0 end as float)),2))/
		(ROUND(sum(cast(case when t.Qty > 0 then t.Qty else 0 end as float)),2)
		-ROUND(SUM(CAST(case when t.Qty < 0 then t.Qty else 0 end as float)),2)))*100 [% Sales],

(ROUND(SUM(cast(case when t.Qty < 0 then t.Qty else 0 end as float)),2))/
		(ROUND(sum(cast(case when t.Qty > 0 then t.Qty else 0 end as float)),2)
		-ROUND(SUM(CAST(case when t.Qty < 0 then t.Qty else 0 end as float)),2))*100 [% Returns]

from Transactions t inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code and t.prod_subcat_code=p.prod_sub_cat_code
group by p.prod_subcat
order by [% sales] desc


--Q11
select  sum(t.total_amt) [Total Revenue]
from ( select t.*, MAX(t.tran_date) over () as Max_transaction
		from Transactions t
	)t inner join Customer c on t.cust_id=c.customer_Id
	where t.tran_date >= DATEADD(day, -30, t.Max_transaction) and
		t.tran_date >= DATEADD(YEAR, 25, c.DOB) and
		t.tran_date <= DATEADD(YEAR, 35, c.DOB)


--Q12

with cte1 as(
	select top 2 prod_cat_code, round(sum(total_amt),2)[Total return amount],dateadd(month, -3,max(tran_date))[Last 3 Months]
	from transactions
	where total_amt < 0
	group by prod_cat_code
	order by round(sum(total_amt),2) asc
	)

	select p.prod_cat
	from prod_cat_info p inner join cte1 c on p.prod_cat_code=c.prod_cat_code
	group by p.prod_cat

--Q13
select top 1 store_type, sum(total_amt) [Sales amount], count(qty)[quantity]
from transactions
where total_amt > 0 and qty > 0
group by store_type
order by [Sales amount] desc, quantity desc


--Q14
select t.prod_cat_code,p.prod_cat, avg(t.total_amt)[average revenue], overallAvg = (select avg(total_amt) from transactions)
from transactions t inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code and t.prod_subcat_code=p.prod_sub_cat_code
group by t.prod_cat_code, p.prod_cat
having avg(t.total_amt) > (select avg(total_amt) from transactions)
order by avg(t.total_amt) 


--Q15
select top 5 p.prod_subcat, avg(t.total_amt) [Average], sum(t.total_amt)[Total Revenue], count(t.qty)[Quantity sold]
from transactions t inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code and t.prod_subcat_code=p.prod_sub_cat_code
group by p.prod_subcat
order by count(t.qty) desc

