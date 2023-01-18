--SQL Advance Case Study
select * from DIM_CUSTOMER
select * from DIM_DATE
select * from DIM_LOCATION
select * from DIM_MANUFACTURER
select * from DIM_MODEL
select * from FACT_TRANSACTIONS
--Q1--BEGIN 
select State
from FACT_TRANSACTIONS t inner join DIM_LOCATION loc on t.IDLocation=loc.IDLocation
	inner join DIM_MODEL m on t.IDModel=m.IDModel
where t.Date between '01-01-2005' and GETDATE()
group by State



--Q1--END

--Q2--BEGIN
select loc.State, COUNT(Quantity)[qty]
from FACT_TRANSACTIONS ft inner join DIM_LOCATION loc on ft.IDLocation=loc.IDLocation
	inner join DIM_MODEL m on m.IDModel=ft.IDModel
	inner join DIM_MANUFACTURER man on m.IDManufacturer=man.IDManufacturer

where man.Manufacturer_Name='Samsung' and loc.Country='US'
group by loc.State



--Q2--END

--Q3--BEGIN      
select m.IDModel, l.ZipCode,l.State, count(IDCustomer)[Transactions]
from FACT_TRANSACTIONS f inner join DIM_MODEL m on f.IDModel=m.IDModel
		inner join DIM_MANUFACTURER m1 on m1.IDManufacturer=m.IDManufacturer
		inner join DIM_LOCATION l on l.IDLocation=f.IDLocation
group by m.IDModel, l.ZipCode, l.State


--Q3--END

--Q4--BEGIN
select top 1 IDModel,m1.Model_Name,m.Manufacturer_Name, max(m1.Unit_price)[Price]
from DIM_MANUFACTURER m inner join DIM_MODEL m1 on m.IDManufacturer=m1.IDManufacturer
group by  m.Manufacturer_Name,Model_Name,IDModel
order by [Price] asc


--Q4--END

--Q5--BEGIN
select f.IDModel, AVG(TotalPrice)[Avg Price],  sum(f.Quantity) [Sales Quantity]
from FACT_TRANSACTIONS f join DIM_MODEL dm on f.IDModel = dm.IDModel
where IDManufacturer in 
	(
		select top 5 IDManufacturer from DIM_MODEL
		where IDModel in
		(
			select top 5 IDModel from FACT_TRANSACTIONS
			group by IDModel
			order by SUM(Quantity) desc
		)
		group by IDManufacturer
	)
group by f.IDModel
order by AVG(TotalPrice)


--Q5--END

--Q6--BEGIN
select c.Customer_Name, AVG(f.TotalPrice)[Average]
from DIM_CUSTOMER c inner join FACT_TRANSACTIONS f on c.IDCustomer=f.IDCustomer
where YEAR(f.Date)=2009 
group by c.Customer_Name
having AVG(TotalPrice) > 500


--Q6--END
	
--Q7--BEGIN  
select * from 
(
	select top 5 m.IDModel,m2.Manufacturer_Name
	from FACT_TRANSACTIONS f 
	left join DIM_MODEL m on f.IDModel = m.IDModel
	left join DIM_MANUFACTURER m2 on m.IDManufacturer = m2.IDManufacturer
	where Year(Date) = '2008'
	group by m.IDModel, m2.Manufacturer_Name
	order by sum(f.Quantity) desc

intersect

	select top 5 m.IDModel, m2.Manufacturer_Name
	from FACT_TRANSACTIONS f 
	left join DIM_MODEL m on f.IDModel = m.IDModel
	left join DIM_MANUFACTURER m2 on m.IDManufacturer = m2.IDManufacturer
	where Year(Date) = '2009'
	group by m.IDModel, m2.Manufacturer_Name
	order by sum(f.Quantity) desc

intersect

	select top 5 m.IDModel, m2.Manufacturer_Name
	from FACT_TRANSACTIONS f 
	left join DIM_MODEL m on f.IDModel = m.IDModel
	left join DIM_MANUFACTURER m2 on m.IDManufacturer = m2.IDManufacturer
	where YEAR(Date) = '2010'
	group by m.IDModel,m2.Manufacturer_Name
	order by sum(f.Quantity) desc
)as A


--Q7--END	

--Q8--BEGIN
---select 2nd top sales in 2009 and 2nd top sales in 2010

with cte1 as
(
		select m.Manufacturer_Name, DATEPART(YEAR,Date) as Yr, RANK() over (partition by DatePart(Year,Date) order by SUM(f.TotalPrice)) as rn1
		from FACT_TRANSACTIONS f 
		inner join DIM_MODEL mo on f.IDModel = mo.IDModel
		inner join DIM_MANUFACTURER m on mo.IDManufacturer = m.IDManufacturer
		group by Manufacturer_Name, DATEPART(YEAR,Date)
		
),
cte2 as
(
		select Manufacturer_Name, Yr
		from cte1 
		where rn1 = 2 and Yr in ('2009', '2010')
)
		select c2.Manufacturer_Name as manu_2009, c1.Manufacturer_Name as manu_2010
		from cte2 as c2, cte1 as c1
		where c2.Yr < c1.Yr and rn1 = 2
		



--Q8--END

--Q9--BEGIN
select m.Manufacturer_Name
from DIM_MANUFACTURER m inner join DIM_MODEL model on m.IDManufacturer=model.IDManufacturer
						inner join FACT_TRANSACTIONS f on f.IDModel = model.IDModel
where YEAR(f.Date) = '2010'

except

select m.Manufacturer_Name
from DIM_MANUFACTURER m inner join DIM_MODEL model on m.IDManufacturer=model.IDManufacturer
						inner join FACT_TRANSACTIONS f on f.IDModel = model.IDModel
where YEAR(f.Date) = '2009'

--Q9--END

--Q10--BEGIN
select t.Customer_Name,t.Year, t.Avg_Price, t.avg_Qty,
case when c.Year is NOT NULL then (CONVERT(decimal(8,1),(c.Avg_Price-t.Avg_Price))*100) /convert(decimal(8,1), c.Avg_Price)
	else NULL end as 'Yearly_%_change'
from (
	select c.Customer_Name, YEAR(t.Date) [Year], AVG(t.Quantity)  as avg_Qty , AVG(t.TotalPrice) as Avg_Price
	from FACT_TRANSACTIONS t 
	inner join DIM_CUSTOMER c on t.IDCustomer=c.IDCustomer
	where t.IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS
	group by IDCustomer
	order by SUM(TotalPrice) desc)
	group by YEAR(Date), c.Customer_Name 
	
	)t
left join 
	( 
	select c.Customer_Name, YEAR(t.Date) [Year], AVG(t.Quantity)  as avg_Qty , AVG(t.TotalPrice) as Avg_Price
	from FACT_TRANSACTIONS t 
	inner join DIM_CUSTOMER c on t.IDCustomer=c.IDCustomer
	where t.IDCustomer in (select top 10 IDCustomer from FACT_TRANSACTIONS
	group by IDCustomer
	order by SUM(TotalPrice) desc)
	group by YEAR(Date), c.Customer_Name 
	)c
on t.Customer_Name=c.Customer_Name and c.Year = t.Year-1  ----self join




--Q10--END
	