use AdventureWorks2014 

select * from AdventureWorks2014.INFORMATION_SCHEMA.TABLES go;	



select * from AdventureWorks2014.INFORMATION_SCHEMA.TABLES go;

select od.SalesOrderID,od.SalesOrderDetailID,od.ProductID,od.ModifiedDate,od.OrderQty
into orderdetails
from Sales.SalesOrderDetail od 

select oh.SalesOrderID,oh.OrderDate,oh.DueDate,oh.ShipDate,cus.customer_name,
oh.SalesPersonID,TaxAmt,c.country,c.city 
into orderheader
from Sales.SalesOrderHeader oh inner join  countires c on c.AddressID = oh.ShipToAddressID inner join customerss cus on cus.Customer_ID =oh.CustomerID
 


select p.ProductID, p.Name product_name ,p.Color,p.StandardCost,cast(p.StandardCost*1.33 as decimal(18,2)) price, p.ProductLine,c.Name categories , sub.Name sub_categories 	  
into items
from Production.Product p inner join Production.ProductSubcategory sub on p.ProductSubcategoryID = sub.ProductSubcategoryID
inner join Production.ProductCategory c on c.ProductCategoryID = sub.ProductCategoryID 

update items set Color = 'Unknown' where Color is null 

update items set ProductLine ='U' where ProductLine is null 


select d.SalesOrderID,d.ModifiedDate,d.ProductID,d.OrderQty,d.OrderQty*i.price sub_toal , i.StandardCost*d.OrderQty total_cost 
into order_details
from items i inner join orderdetails d on d.ProductID =i.ProductID


select * ,
case when d.sub_totals > 1500 then 'Class A' when d.sub_totals > 1000 then 'Class B' when d.sub_totals >500 then 'Class C' else 'Class D' end as customer_classs
into order_heads
from (
select d.SalesOrderID salesid, sum(d.OrderQty) quantities , sum(d.sub_toal) as sub_totals, sum(d.total_cost) cost_total
from order_details d 
group by d.SalesOrderID
) d  inner join orderheader h on h.SalesOrderID = d.salesid



select y.Classes,i.ProductID,i.product_name,i.categories,i.sub_categories,i.price,i.Color,i.ProductLine,i.StandardCost
into items_final
from(
 select x.sub_categories, case when pct >=0.2 then 'Class A' when pct >=0.005 then 'Class B' else 'Class D' end as Classes
 from (select i.categories , i.sub_categories , sum(o.sub_toal) totals ,sum(o.sub_toal)/(select sum(sub_toal) from order_details) pct
from order_details o inner join items i on i.ProductID =o.ProductID 
group by i.categories , i.sub_categories
) x)y inner join items i on i.sub_categories = y.sub_categories
  



select d.Name ,CONCAT( p.FirstName,' ', p.LastName) emp_name, emp.BusinessEntityID,emp.BirthDate,emp.HireDate,emp.Gender,emp.JobTitle,emp.MaritalStatus
into emps
from HumanResources.Department d inner join HumanResources.EmployeeDepartmentHistory dep on 
d.DepartmentID= dep.DepartmentID inner join HumanResources.Employee emp on emp.BusinessEntityID =dep.BusinessEntityID 
inner join  Person.Person p on p.BusinessEntityID = emp.BusinessEntityID

 


select *,(jan+feb+mar+apr+may+June+jul+aug+sep+oct+nov+dec) totals from(
select dd.years,
cast(sum(case when dd.months like '%Ja%' then dd.sub_totals else 0 end) as decimal (18,2)) jan ,
cast(sum(case when dd.months like '%Fe%' then dd.sub_totals else 0 end) as decimal (18,2)) Feb ,
cast(sum(case when dd.months like '%Mar%' then dd.sub_totals else 0 end) as decimal (18,2)) Mar ,
cast(sum(case when dd.months like '%Ap%' then dd.sub_totals else 0 end) as decimal (18,2)) Apr ,
cast(sum(case when dd.months like '%May%' then dd.sub_totals else 0 end) as decimal (18,2)) May ,
cast(sum(case when dd.months like '%Jun%' then dd.sub_totals else 0 end) as decimal (18,2)) June ,
cast(sum(case when dd.months like '%Jul%' then dd.sub_totals else 0 end) as decimal (18,2)) Jul ,
cast(sum(case when dd.months like '%Aug%' then dd.sub_totals else 0 end) as decimal (18,2)) Aug ,
cast(sum(case when dd.months like '%Sep%' then dd.sub_totals else 0 end) as decimal (18,2)) Sep ,
cast(sum(case when dd.months like '%Oc%' then dd.sub_totals else 0 end) as decimal (18,2)) Oct ,
cast(sum(case when dd.months like '%No%' then dd.sub_totals else 0 end) as decimal (18,2)) Nov ,
cast(sum(case when dd.months like '%De%' then dd.sub_totals else 0 end) as decimal (18,2)) Dec 
from  (
select * ,DATEPART(YEAR,h.OrderDate) years ,CONCAT('Q', DATEPART(QUARTER,h.OrderDate)) quarter , format(h.OrderDate , 'MMM') months , 
CONCAT(FORMAT(h.OrderDate,'MMM'),'_',datepart(year,h.OrderDate)) month_year
from order_heads h
) dd group by dd.years) a


select * ,(x.Y2011+x.Y2012+x.Y2013+x.Y2014 ) total ,(x.Y2011+x.Y2012+x.Y2013+x.Y2014 )/(select sum(o.sub_toal) from order_details o)
from (
select i.categories,   
CAST(sum(case when  year(h.OrderDate) = 2011 then  d.sub_toal else 0 end) as decimal (18,2)) Y2011,
CAST(sum(case when  year(h.OrderDate) = 2012 then  d.sub_toal else 0 end) as decimal (18,2)) Y2012,
CAST(sum(case when  year(h.OrderDate) = 2013 then  d.sub_toal else 0 end) as decimal (18,2)) Y2013,
CAST(sum(case when  year(h.OrderDate) = 2014 then  d.sub_toal else 0 end) as decimal (18,2)) Y2014
from order_heads h inner join order_details d on d.SalesOrderID = h.SalesOrderID inner join items i on i.ProductID = d.ProductID 
group by i.categories 
) x



create view items_classes_total as 
select i.Classes,i.categories,i.sub_categories,i.product_name,sum(o.sub_toal) sub_total,sum(o.total_cost) cost,count(*) orders
from items_final i inner join order_details o on o.ProductID = i.ProductID
group by i.Classes,i.categories,i.sub_categories,i.product_name 
 

  

  select * from items_final
  select * from order_heads
  select * from order_details
  select * from items_classes_total
  

  create view items_classes_years as 
  select *,(Y11+Y12+Y13+Y14) totals , cast ((Y11+Y12+Y13+Y14) /(select sum(h.sub_totals) from order_heads h) as decimal(18,4)) pct
  from(
  select i.Classes,i.categories,i.sub_categories,i.product_name , 
  cast(sum(case when year(d.ModifiedDate) =2011 then d.sub_toal else 0 end ) as decimal(18,2)) as Y11,
  cast(sum(case when year(d.ModifiedDate) =2012 then d.sub_toal else 0 end ) as decimal(18,2)) as Y12,
  cast(sum(case when year(d.ModifiedDate) =2013 then d.sub_toal else 0 end ) as decimal(18,2)) as Y13,
  cast(sum(case when year(d.ModifiedDate) =2014 then d.sub_toal else 0 end ) as decimal(18,2)) as Y14
  from order_details d inner join items_final i on i.ProductID = d.ProductID 
group by i.Classes,i.categories,i.sub_categories,i.product_name
)x  



select * from items_classes_years


create view countries_totals as 
select *,(Y11+Y12+Y13+Y14) totals,cast((Y11+Y12+Y13+Y14)/(select sum(h.sub_totals) from order_heads h) as decimal(18,4)) pct
from(
select h.country,count(*) customers,
CAST(sum(case when year(h.OrderDate) = 2011 then h.sub_totals else 0 end) as decimal(18,2)) Y11,
CAST(sum(case when year(h.OrderDate) = 2011 then h.sub_totals else 0 end) as decimal(18,2)) Y12,
CAST(sum(case when year(h.OrderDate) = 2011 then h.sub_totals else 0 end) as decimal(18,2)) Y13,
CAST(sum(case when year(h.OrderDate) = 2011 then h.sub_totals else 0 end) as decimal(18,2)) Y14
from order_heads h
group by h.country)x
 


 create view categories_clasess_ym as 
 select *,  (x.Jan+x.Feb+x.Mar+x.Apr+x.May+x.Jun+x.Jul+x.Aug+x.Sep+x.Oct+x.Nov+x.Dec) total
 from (
 select i.Classes,DATEPART(YEAR,h.ModifiedDate) year,
 CAST(sum(case when FORMAT(h.ModifiedDate,'MMM') ='Jan' then h.sub_toal else 0 end) as decimal(18,2)) Jan,
  CAST(sum(case when FORMAT(h.ModifiedDate,'MMM') ='Feb' then h.sub_toal else 0 end) as decimal(18,2)) Feb,
   CAST(sum(case when FORMAT(h.ModifiedDate,'MMM') ='Mar' then h.sub_toal else 0 end) as decimal(18,2)) Mar,
    CAST(sum(case when FORMAT(h.ModifiedDate,'MMM') ='APr' then h.sub_toal else 0 end) as decimal(18,2)) Apr,
	 CAST(sum(case when FORMAT(h.ModifiedDate,'MMM') ='May' then h.sub_toal else 0 end) as decimal(18,2)) May,
	  CAST(sum(case when FORMAT(h.ModifiedDate,'MMM') ='Jun' then h.sub_toal else 0 end) as decimal(18,2)) Jun,
	   CAST(sum(case when FORMAT(h.ModifiedDate,'MMM') ='Jul' then h.sub_toal else 0 end) as decimal(18,2)) Jul,
	    CAST(sum(case when FORMAT(h.ModifiedDate,'MMM') ='Aug' then h.sub_toal else 0 end) as decimal(18,2)) Aug,
		 CAST(sum(case when FORMAT(h.ModifiedDate,'MMM') ='Sep' then h.sub_toal else 0 end) as decimal(18,2)) Sep,
		  CAST(sum(case when FORMAT(h.ModifiedDate,'MMM') ='Oct' then h.sub_toal else 0 end) as decimal(18,2)) Oct,
		   CAST(sum(case when FORMAT(h.ModifiedDate,'MMM') ='Nov' then h.sub_toal else 0 end) as decimal(18,2)) Nov,
		    CAST(sum(case when FORMAT(h.ModifiedDate,'MMM') ='Dec' then h.sub_toal else 0 end) as decimal(18,2)) Dec
 from order_details h inner join items_final i on i.ProductID = h.ProductID
 group by i.Classes,DATEPART(YEAR,h.ModifiedDate) )x
 
 


 select * from items_final

select * from order_details
select * from order_heads



select *,o.sub_toal from order_details o















select * 
from order_heads h 
where YEAR(h.OrderDate) = YEAR(GETDATE()) - 1 YEAR



create table data (no int ,items varchar(50),prices decimal(18,2),qty int , date date , total decimal(18,2));


select *,YEAR(d.date) from data d  

 
 select * from data

 exec sp_rename  'data.date' , 'dates'

 

 select * ,string_split(dates,'-',1) from data



  




















