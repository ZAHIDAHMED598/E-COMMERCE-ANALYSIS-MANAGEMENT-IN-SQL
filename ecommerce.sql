create database mini_project;
use mini_project;
select * from customers_new;

#since the data is uncleaned,so we need to clean the data first
#Rename the columnid
ALTER TABLE customers_new RENAME COLUMN ï»¿customer_Id TO customer_id;

#Query to remove unused column from the table customers_new
ALTER TABLE customers_new DROP COLUMN MyUnknownColumn;
ALTER TABLE customers_new DROP COLUMN `MyUnknownColumn_[0]`;
ALTER TABLE customers_new DROP COLUMN `MyUnknownColumn_[1]`;
ALTER TABLE customers_new DROP COLUMN `MyUnknownColumn_[2]`;

#THE DATA IS CLEAN INSIDE THIS TABLE prod_cat_info
SELECT * FROM prod_cat_info;

SELECT * FROM transactions_new;

#SINCE THE COLUMN NAME IS NOT CORRECT IN THE TRANSACTIONS TABLE,SO LET US RENAME THE COLUMN NAME USING ALTER COMMAND
ALTER TABLE transactions_new RENAME column ï»¿transaction_id TO transaction_id;



#DATA PREPARATION AND UNDERSTANDINNG
#1.WHAT IS THE TOTAL NO OF ROWS IN EACH OF THE 3 TABLES IN THE DATABASE
SELECT 
    COUNT(*)
FROM
    customers_new;
#ANS. THERE ARE 5645 ROWS IN THE CUSTOMERS TABLE
SELECT 
    COUNT(*)
FROM
    prod_cat_info;
#ANS. THERE ARE 23 ROWS IN THE PRODUCT TABLE
SELECT 
    COUNT(*)
FROM
    transactions_new;
#ANS. THERE ARE 23053 ROWS IN THE TRANSACTIONS TABLE


#2.WHAT IS THE TOTAL NO OF TRANSACTIONS THAT HAVE A RETURN?
#ANS.THERE ARE 2177 TRANSACTIONS THAT HAVE A RETURN

SELECT 
    COUNT(total_amt)
FROM
    transactions_new
WHERE
    total_amt < 0;



#3.AS YOU WOULD HAVE NOTICED THAT,THE DATES PROVIDED ACROSS THE DATASETS ARE NOT IN A CORRECT FORMAT
# AS FIRST STEP,PLZ CONVERT THE DATE VARIABLES INTO VALID  DATE FORMATS,BEFORE PROCEEDING AHEAD?
DESC transactions_new;
DESC customers_new;
#WHEN WE SEE THE FORMAT OF DOB IN THE CUSTOMERS TABLE AND TRAN-DATE IN THE TRANSACTION TABLE, 
#IT IS IN TEXT FORMAT
# WE NEED TO CONVERT THE TEXT FORMAT INTO DATE FORMAT USING ALTER COMMAND
SELECT * FROM customers_new;
ALTER TABLE customers_new MODIFY COLUMN DOB datetime;

#BUT USING ALTER COMMAND,WE GET THE ERROR,
#SO FIRST WE NEED TO CONVERT THE DATE FORMAT TO DEFAULT DATE FORMAT
#DEFAULT DATE FORMAT IN MYSQL IS ("YYYY-MM-DD")
#TO CONVERT TO DEFAULT DATE FORMAT WE USE UPDATE COMMAND
update customers_new 
set DOB=str_to_date(DOB,"%d-%m-%Y");

DESC customers_new;
ALTER TABLE customers_new MODIFY COLUMN DOB date;

alter table transactions_new modify tran_date date;

update transactions_new
set tran_date=str_to_date(tran_date,"%d-%m-%Y");


/* #4.WHAT IS THE TIME RANGE OF TRANSACTION DATA AVAILABLE FOR ANALYSIS?SHOW THE OUTPUT IN NO OF DAYS,
   MONTHS AND YEARS SIMULTANEOUSLY IN DIFFERENT COLUMNS*/
select tran_date,datediff(day,12,13) from transactions_new;  
desc transactions_new;
    
 #EXTRACT FUNCTION EXTRACTS THE PART FROM A GIVEN DATE
 SELECT tran_date,extract(YEAR FROM tran_date) AS YEAR,
 extract(month from tran_date) as MONTH,
 extract(day from tran_date) as DAY
 from transactions_new;
                       #OR
#year function,month function & day function gives the part of the date.
SELECT tran_date,year(tran_date) as years,month(tran_date) as months,
day(tran_date) as days from transactions_new;
 
select DOB,EXTRACT(YEAR FROM DOB) AS YEAR,
EXTRACT(MONTH FROM DOB) AS MONTH,
EXTRACT(DAY FROM DOB) AS DAY
from customers_new;

#5.WHICH PRODUCT CATEGORY DOES THE SUB CATEGORY "DIY" BELONGS TO?
SELECT 
    prod_cat, prod_subcat
FROM
    prod_cat_info
WHERE
    prod_subcat = 'DIY';
#ANS DIY BELONGS TO BOOKS CATEGORY

#DATA ANALYSIS

#1.WHICH CHANNEL IS MOST FREQUENTLY USED FOR TRANSACTION?
SELECT 
    Store_type, COUNT(transaction_id) AS NO_OF_TRANSACTIONS
FROM
    transactions_new
GROUP BY Store_type
ORDER BY NO_OF_TRANSACTIONS DESC
LIMIT 1;
#E-SHOP CHANNEL IS MORE FREQUENTLY USED FOR TRANSACTONS i.e 9311 (dt)


#2.WHAT IS THE COUNT OF MALE AND FEMALE CUSTOMERS IN THE DATABASE?
SELECT count(Gender) as NO_OF_MALES FROM  customers_new
where Gender="M";

SELECT count(Gender) as NO_OF_FEMALES FROM  customers_new
where Gender="F";

select Gender,count(customer_id) as NO_OF_CUSTOMERS from customers_new
group by Gender
having Gender="M" or Gender="F";


#3.FROM WHICH CITY DO WE HAVE THE MAXIMUM NO OF CUSTOMERS AND HOW MANY?

SELECT 
    city_code, COUNT(customer_id) AS NO_OF_CUSTOMERS
FROM
    customers_new
GROUP BY city_code
ORDER BY NO_OF_CUSTOMERS DESC
LIMIT 1;
#ANS CITY CODE 3 HAS MAXIMUM NO OF CUSTOMERS.AND THERE ARE 595 CUSTOMERS IN THE CITY-CODE 3


#4.HOW MANY SUB CATEGORIES ARE THERE UNDER THE BOOKS CATEGORY?
SELECT 
    prod_cat, COUNT(prod_subcat) AS NO_OF_SUBCATEGORIES
FROM
    prod_cat_info
GROUP BY prod_cat
HAVING prod_cat = 'Books';
#ANS THERE ARE 6 SUB CATEGORIES IN THE BOOK CATEGORY.

#5.WHAT IS THE MAXIMUM QUANTITY OF PRODUCTS EVER ORDERED?
SELECT 
    MAX(Qty) AS HIGHEST_QUANTITY
FROM
    transactions_new;
    
#ANS 5 PRODUCTS ARE ORDERED MAXIMUM.
#6.WHAT IS THE NET TOTAL REVENUE GENERATED IN CATEGORIES ELECTRONICS AND BOOKS?

SELECT 
    prod_cat, ROUND(SUM(total_amt), 2) AS NET_AMT
FROM
    transactions_new TN
        INNER JOIN
    prod_cat_info PC ON TN.prod_subcat_code = PC.prod_sub_cat_code
        AND TN.prod_cat_code = PC.prod_cat_code
GROUP BY prod_cat
HAVING prod_cat IN ('Electronics' , 'Books');                       

   #HAVING prod_cat="Electronics" or prod_cat="Books";
#ANS. ELECTRONICS HAS 10722463 AND BOOKS HAS 12822694

             
#7.HOW MANY CUSTOMERS HAVE > 10 TRANSACTIONS WITH US EXCLUDING RETURNS

SELECT cust_id,transaction_id,sum(Qty) FROM transactions_new
WHERE Qty >0
group by cust_id,transaction_id;


SELECT cust_id,COUNT(transaction_id) AS NO_OF_TRANSACTIONS FROM transactions_new
GROUP BY cust_id
HAVING NO_OF_TRANSACTIONS > 10
ORDER BY NO_OF_TRANSACTIONS DESC;

SELECT SUM(NO_OF_TRAN)  FROM (SELECT cust_id,COUNT(transaction_id) AS NO_OF_TRAN FROM transactions_new
GROUP BY cust_id
HAVING COUNT(transaction_id)>10) AS XYZ;

/* #8.WHAT IS THE COMBINED REVENUE EARNED FROM THE ELECTRONICS
 AND CLOTHING CATEGORIES FROM FLAGSHIP STORES? */


select sum(NET_AMT) AS COMBINED_REVENUE FROM 
(SELECT prod_cat,round(SUM(total_amt),2) as NET_AMT 
FROM transactions_new TN
INNER JOIN prod_cat_info PC
ON TN.prod_subcat_code=PC.prod_sub_cat_code 
AND TN.prod_cat_code=PC.prod_cat_code
GROUP BY prod_cat
HAVING prod_cat IN ("Electronics","Clothing"))as xyz;

#ANS.16973601.12

/*#9.WHAT IS THE TOTAL REVENUE GENERATED FROM MALE CUSTOMERS
 IN ELECTRONICS CATEGORY?OUTPUT SHOULD DISPLAY TOTAL REVENUE BY PROD_SUB_CAT */


SELECT Gender,round(sum(total_amt),0) AS TOTAL_REVENUE,prod_cat
FROM transactions_new TN
INNER JOIN prod_cat_info PC
INNER JOIN customers_new CN
ON TN.prod_subcat_code=PC.prod_sub_cat_code 
AND TN.prod_cat_code=PC.prod_cat_code 
AND CN.customer_id=TN.cust_id
group by Gender,prod_cat
having Gender="M" and prod_cat="Electronics";

#ans.THE TOTAL REVENUE GENERATED BY MALE CUSTOMERS ARE 5697629

/* #10.WHAT IS PERCENTAGE OF SALES AND RETURNS BY PRODUCT SUBCATEGORY.DISPLAY ONLY TOP 5 
SUB CATEGORIES IN TERMS OF SALES */

SELECT prod_subcat,round(sum(total_amt),0) as TOTAL_AMT FROM transactions_new T
INNER JOIN prod_cat_info P
ON T.prod_subcat_code=P.prod_sub_cat_code AND T.prod_cat_code=P.prod_cat_code
WHERE T.Qty> 0
group by prod_subcat
order by TOTAL_AMT DESC
LIMIT 5;

/* #11.FOR ALL CUSTOMERS AGED BETWEEN 25 TO 35 YEARS FIND WHAT IS THE NET TOTAL REVENUE
       GENERATED BY THESE CUSTOMERS IN LAST 30 DAYS OF TRANSACTIONS FROM MAX TRANSACTIONS DATE
       AVAILABLE IN THE DATA?  */

SELECT * FROM prod_cat_info;
SELECT * FROM transactions_new;
SELECT * FROM customers_new;
SELECT * FROM big_shop_sales;       
       
with XYZ as 
(select C.customer_id, year(curdate())-date_format(str_to_date(DOB,'%d-%m-%Y'),'%Y') as Age,T.tran_date,T.total_amt from customers_new C
inner join transactions_new T
on C.customer_id = T.cust_id
order by T.tran_date desc)
select customer_id,tran_date,Age,sum(total_amt) as Total_sum from XYZ
group by customer_id,tran_date,Age
having Age between 25 and 35
order by Total_sum desc, tran_date desc
limit 30;       
       
       
       
       
       
       
/* #12.WHICH PRODUCT CATEGORY HAS SEEN THE MAX VALUE OF RETURNS IN THE LAST 3 MONTHS OF 
	  TRANSACTIONS? */
SELECT prod_cat,round(sum(total_amt),1) as TA  FROM transactions_new T
INNER JOIN prod_cat_info P
ON T.prod_cat_code=P.prod_cat_code AND T.prod_subcat_code=P.prod_sub_cat_code
WHERE total_amt <0 
group by prod_cat
order by TA ASC;

/* #13.WHICH STORE TYPE SELLS THE MAXIMUM PRODUCTS BY VALUE OF SALES AMOUNT AND BY QUANTITY SOLD*/
SELECT Store_type,SUM(Qty) AS QUANTITY,ROUND(SUM(total_amt),2) AS SALES_AMOUNT FROM transactions_new
group by Store_type
ORDER BY QUANTITY DESC, SALES_AMOUNT DESC
LIMIT 1;


/* #14. WHAT ARE THE CATEGORIES FOR WHICH AVERAGE REVENUE IS ABOVE THE OVERALL AVERAGE.*/
SELECT * FROM prod_cat_info;
SELECT * FROM transactions_new;










/* #15.FIND THE AVERAGE AND TOTAL REVENUE BY EACH SUBCATEGORY FRO THE CATEGORIES WHICH ARE AMONG 
    TOP 5 CATEGORIES IN TERMS OF QUANTITY SOLD */
