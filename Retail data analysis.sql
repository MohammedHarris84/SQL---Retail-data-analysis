create database Retail_data_analysis;


--DATA PREPARATION AND UNDERSTANDING

--Q1)
 select count(*) from Customer
 union
 select count(*) from prod_cat_info
 union
 select count(*) from Transactions;



 --Q2)
 select COUNT(distinct(transaction_id)) as No_of_transaction from Transactions
 where Qty < 0;



 --Q3)
 select CONVERT(date, tran_date,105) as transaction_dates
 from Transactions;



 --Q4)
 select DATEDIFF(YEAR,MIN(CONVERT(date, tran_date,105)),MAX(CONVERT(date, tran_date,105))) as Diff_Years,
 DATEDIFF(MONTH,MIN(CONVERT(date, tran_date,105)),MAX(CONVERT(date, tran_date,105))) as Diff_Months,
 DATEDIFF(DAY,MIN(CONVERT(date, tran_date,105)),MAX(CONVERT(date, tran_date,105))) as Diff_Days
 from Transactions;



 --Q5)
 select prod_cat,prod_subcat from prod_cat_info
 where prod_subcat = 'DIY';



 --DATA ANALYSIS

 --Q1)
 select top 1 store_type,COUNT(*) as CNT from Transactions
 group by Store_type
 order by CNT desc;


 --Q2)
 select gender, COUNT(*) as CNT from Customer
 where gender is not null
 group by Gender;


 --Q3)
 select top 1 city_code,COUNT(*) as CNT from Customer
 group by city_code
 order by CNT desc;


 --Q4)
 select prod_cat,prod_subcat from prod_cat_info
 where prod_cat = 'Books';


 --Q5)
 select prod_cat_code, MAX(Qty) as Max_product from Transactions
 group by prod_cat_code;


 --Q6)
 select SUM(cast (total_amt as float)) as Net_revenue from prod_cat_info as T1
 join Transactions as T2
 on T1.prod_cat_code = T2.prod_cat_code	and T1.prod_sub_cat_code = T2.prod_subcat_code
 where prod_cat = 'Books' or prod_cat = 'Electronics';


 --Q7)
 select COUNT(*) as tot_cust from(
 select cust_id, COUNT(distinct(transaction_id)) as CNT_trans from Transactions
 where Qty > 0
 group by cust_id
 having COUNT(distinct(transaction_id)) > 10) as T05;


 --Q8)
 select SUM(cast (total_amt as float)) as Combined_revenue from prod_cat_info as T1
 join Transactions as T2
 on T1.prod_cat_code = T2.prod_cat_code	and T1.prod_sub_cat_code = T2.prod_subcat_code
 where prod_cat in ('Clothing','Electronics') and store_type = 'Flagship store'and qty > 0;


 --Q9)
 select prod_subcat,SUM(cast(total_amt as float)) as  tot_revenue from Customer as T1
 join Transactions as T2
 on T1.customer_Id = T2.cust_id
 join prod_cat_info as T3
 on T2.prod_cat_code = T3.prod_cat_code and T2.prod_subcat_code = T3.prod_sub_cat_code
 where gender = 'm' and prod_cat = 'Electronics'
 group by prod_subcat;


 --Q10)

 --Percentage of Sales
 SELECT T4.prod_subcat, Percentage_of_Sales, Percentage_of_Return FROM (
 select Top 5 prod_subcat, (SUM (CAST(TOTAL_AMT AS FLOAT))/(SELECT SUM (CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_SALES FROM Transactions WHERE Qty > 0)) AS Percentage_of_Sales
 from prod_cat_info join Transactions
 on prod_cat_info.prod_cat_code = Transactions.prod_cat_code and prod_cat_info.prod_sub_cat_code = Transactions.prod_subcat_code
 WHERE Qty > 0
 GROUP BY prod_subcat
 ORDER BY Percentage_of_Sales DESC)AS T4 JOIN

 --Percentage of Return
 (
 select  prod_subcat,(SUM (CAST (TOTAL_AMT AS FLOAT))/(SELECT SUM (CAST (TOTAL_AMT AS FLOAT)) AS TOTAL_SALES FROM Transactions WHERE Qty < 0)) AS Percentage_of_Return
 from prod_cat_info join Transactions
 on prod_cat_info.prod_cat_code = Transactions.prod_cat_code and prod_cat_info.prod_sub_cat_code = Transactions.prod_subcat_code
 WHERE Qty < 0
 GROUP BY prod_subcat) AS T5
 ON T4.prod_subcat=T5.prod_subcat;



 --Q11)

 -- Age of customer
 select * from(

select * from(
select cust_id, DATEDIFF(YEAR,dob,max_date) as Age, revenue from(
select cust_id,dob, max(convert(date, tran_date,105)) as Max_date, SUM(cast(total_amt as float)) as revenue from Customer as T1
join Transactions as T2
on T1.customer_Id = T2.cust_id
where Qty > 0
group by cust_id,DOB) as A
) as B
where Age between 25 and 35
)as C

join(
--Last 30 days of transactions

select cust_id,(convert(date,tran_date,105)) as tran_date 
from Transactions
group by cust_id, (convert(date,tran_date,105))
having (convert(date,tran_date,105) >= (select DATEADD(DAY, -30,max (convert(date,tran_date,105))) as cutoff_date from Transactions)
))as D
on c.cust_id = d.cust_id;



--Q12)

select top 1 prod_cat_code, SUM(Returns) as tot_returns from(

select prod_cat_code, convert(date,tran_date,105) as tran_date, sum (Qty) as Returns
from Transactions
where Qty < 0
group by prod_cat_code, convert(date,tran_date,105)
having convert(date,tran_date,105) >= (select DATEADD(MONTH, -3,max (convert(date,tran_date,105))) as cutoff_date from Transactions)
) as A
group by prod_cat_code
order by tot_returns;


--Q13)

select store_type, SUM(cast(total_amt as float)) as revenue, SUM(Qty) as quantity
from Transactions
where Qty > 0
group by Store_type
order by revenue desc, quantity desc;


--Q14)

select prod_cat_code, AVG(cast(total_amt as float)) as avg_revenue
from Transactions
where Qty > 0
group by prod_cat_code
having AVG(cast(total_amt as float)) >= (select AVG(cast(total_amt as float)) from Transactions
where Qty > 0);


--Q15)

select prod_subcat_code, sum(cast(total_amt as float)) as revenue, AVG(cast(total_amt as float)) as avg_revenue
from Transactions
where Qty > 0 and prod_cat_code
in (select top 5 prod_cat_code from Transactions
where Qty > 0
group by prod_cat_code
order by sum(Qty) desc)
group by prod_subcat_code;


