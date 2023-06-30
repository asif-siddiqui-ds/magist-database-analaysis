#=======================================================
#What categories of tech products does Magist have?

select * from product_category_name_translation
where product_category_name_english in ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image");
#============================================
#How many products of these tech categories have been sold

SELECT COUNT(*) AS n_orders
FROM order_items
LEFT JOIN products p ON p.product_id = order_items.product_id
LEFT JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where product_category_name_english in ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image");

#====================================================
#What percentage does that represent from the overall number of products sold?

SELECT COUNT(*) AS n_orders, count(*)*100/112650 as total_percentage
FROM order_items
LEFT JOIN products p ON p.product_id = order_items.product_id
LEFT JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where product_category_name_english in ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image");

#================================

SELECT 
    (SELECT COUNT(*) 
     FROM order_items oi
     JOIN products p ON oi.product_id = p.product_id
     JOIN product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
     WHERE pcnt.product_category_name_english IN ('audio', 'consoles_games', 'electronics', 'computers', 'computers_accessories', 'pc_gamer','telephony','tablets_printing_image')
    ) / COUNT(*) * 100 as Percentage_tech_products_sold
FROM order_items;
#========================================================
#What’s the average price of the products being sold?

select avg(price)
from order_items;

#========================================================
#Are expensive tech products popular? 

select count(*),
case when price < 110 then 'low'
when price >= 110 and price < 130 then 'average'
else 'high'
end as Price_Category
from order_items
Left Join products on order_items.product_id = products.product_id
left join product_category_name_translation on products.product_category_name = product_category_name_translation.product_category_name
where product_category_name_english in('audio', 'console_games', 'electronics', 'computers', 'computer_accessories', 'pc_gamer', 'telephony', 'tablet_printing_image') 
group by Price_Category;

#=======================================
#Tech vs non-tech products (BONUS)
SELECT 
	(SELECT count(*) FROM order_items
	LEFT JOIN products p ON p.product_id = order_items.product_id
	LEFT JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
	WHERE pc.product_category_name_english IN ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image")
	) AS tech_prods, 
    (SELECT count(*) FROM order_items
	LEFT JOIN products p ON p.product_id = order_items.product_id
	LEFT JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
	WHERE pc.product_category_name_english NOT IN ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image")
	) AS non_tech_prods,
    
    (SELECT count(*) FROM order_items
	LEFT JOIN products p ON p.product_id = order_items.product_id
	LEFT JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
	WHERE pc.product_category_name_english IN ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image")
	) / 
    (SELECT count(*) FROM order_items
	LEFT JOIN products p ON p.product_id = order_items.product_id
	LEFT JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
	WHERE pc.product_category_name_english NOT IN ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image") 
	) * 100 AS non_tech_prods
    
FROM order_items
group by tech_prods, non_tech_prods;

SELECT
	CASE 
		WHEN pc.product_category_name_english IN ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image")
		THEN "tech_prods"
		WHEN pc.product_category_name_english NOT IN ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image")
		THEN "non_tech_prods"
	end as prod_cat,
    count(*)
  
FROM order_items
LEFT JOIN products p ON p.product_id = order_items.product_id
LEFT JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
group by prod_cat;

#========================================================
#How many months of data are included in the magist database?

SELECT 
TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), 
MAX(order_purchase_timestamp)) AS months_of_data 
FROM orders;

#===========================================
SELECT 
	(select count(distinct s.seller_id) 
	from sellers s
	LEFT JOIN order_items as oi ON oi.seller_id = s.seller_id
	) as total_sellers,
    
    (select count(distinct s.seller_id) 
	from sellers s
	LEFT JOIN order_items as oi ON oi.seller_id = s.seller_id
	LEFT JOIN products as p ON p.product_id = oi.product_id
	LEFT JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
	where product_category_name_english in ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image")
	) as tech_sellers, 
    
    (select count(distinct s.seller_id) 
	from sellers s
	LEFT JOIN order_items as oi ON oi.seller_id = s.seller_id
	LEFT JOIN products as p ON p.product_id = oi.product_id
	LEFT JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
	where product_category_name_english in ("audio", "computers", "consoles_games", "pc_gamer",
					"electronics", "computers_accessories", "telephony", "tablets_printing_image"))
	/
    (select count(distinct s.seller_id) 
	from sellers s
	LEFT JOIN order_items as oi ON oi.seller_id = s.seller_id) 
    
	* 100 as tech_percentage
    
from sellers
group by tech_sellers, total_sellers;

SELECT count(distinct s.seller_id) as tech_sellers, count(distinct s.seller_id)*100/3065 as total_percentage
from sellers s
INNER JOIN order_items as oi ON oi.seller_id = s.seller_id
INNER JOIN products as p ON p.product_id = oi.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where product_category_name_english in ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image");

#==================================================
#What is the total amount earned by all sellers? 
#What is the total amount earned by all Tech sellers?

SELECT round(sum(oi.price)) as all_sellers_earning, 
(SELECT round(sum(oi.price))
from order_items as oi
INNER JOIN products as p ON p.product_id = oi.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where pc.product_category_name_english in ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image")
and p.product_id = oi.product_id) as tech_seller_earning

from order_items as oi;

SELECT pc.product_category_name_english, sum(op.payment_value)
from order_payments as op
inner join order_items as oi on op.order_id = oi.order_id
INNER JOIN products as p ON p.product_id = oi.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where pc.product_category_name_english in ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image")
and p.product_id = oi.product_id

group by pc.product_category_name_english;

#==================================================
# average monthly income of all sellers?

SELECT 
	DATE_FORMAT(orders.order_purchase_timestamp, '%Y-%m') AS income_month,
    round(avg(oi.price)) as monthly_average_income 
FROM orders  
INNER JOIN order_items oi on oi.order_id = orders.order_id
group by income_month
order by income_month;

# average monthly income of tech sellers?

SELECT 
	seller_id, DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS income_month,
    round(avg(oi.price)) as monthly_average_income 
FROM orders  
INNER JOIN order_payments op on op.order_id = orders.order_id
INNER JOIN order_items oi on oi.order_id = orders.order_id
INNER JOIN products as p ON p.product_id = oi.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where pc.product_category_name_english in ("audio", "computers", "consoles_games", "pc_gamer",
						"electronics", "computers_accessories", "telephony", "tablets_printing_image")
group by income_month, seller_id
order by income_month;

#==============================================
# What’s the average time between the order being placed and the product being delivered?

select 
round(avg(timestampdiff(day, order_purchase_timestamp, order_delivered_customer_date)), 1) as av_tim_diff
from orders
where order_status = "delivered";

#=================================================
#How many orders are delivered on time vs orders delivered with a delay?

select order_id, order_estimated_delivery_date, order_delivered_customer_date,
	case 
		when datediff(order_estimated_delivery_date, order_delivered_customer_date) >= 0
        then "on_time_delivery"
        else
        "deleyed_delivery"
    end as order_vs_delieverd
from orders
where order_status = "delivered";

#===================================
select	
	COUNT(*) AS total_orders,
	COUNT(
		IF(order_delivered_customer_date < order_estimated_delivery_date,
			order_id, NULL)
		) as onTime_delivery,
	COUNT(
		IF( order_delivered_customer_date > order_estimated_delivery_date,
			order_id, NULL)
		) as delayed_delivery
from orders
where order_status = "delivered";

#========================================
SELECT 
    AVG(TIMESTAMPDIFF(DAY,
        order_purchase_timestamp,
        order_delivered_customer_date)) AS average_delivery_time_in_days
FROM
    orders;
 #==============================================   
SELECT 
    COUNT(*) AS total_orders,
    SUM(CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1
        ELSE 0
    END) AS on_time_orders,
    COUNT(*) - SUM(CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1
        ELSE 0
    END) AS delayed_orders
FROM
    orders
where order_status = "delivered";


#=================================
select 
	COUNT(order_id),
    case when
		datediff(order_estimated_delivery_date, order_delivered_customer_date) >= 0
		then "onTime_delivery" else "delayed_delivery"
	end as onTime_vs_delayed 
from orders
where order_status = "delivered"
group by onTime_vs_delayed;

#===================================
#Is there any pattern for delayed orders, e.g. big products being delayed more often?

select pc.product_category_name_english, 
		orders.order_estimated_delivery_date, 
        orders.order_delivered_customer_date,
	(select
		datediff(orders.order_estimated_delivery_date, orders.order_delivered_customer_date) 
        having datediff(orders.order_delivered_customer_date, orders.order_estimated_delivery_date) > 0) 
        as time_on_delayed_delivery
    
from order_items
inner join orders on orders.order_id = order_items.order_id
INNER JOIN products as p ON p.product_id = order_items.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where datediff(orders.order_delivered_customer_date, orders.order_estimated_delivery_date) > 0 
and orders.order_status = "delivered"
order by time_on_delayed_delivery;

#============================================

select pc.product_category_name_english,
		count(*) as n_items_orders,
        COUNT(
			IF( orders.order_delivered_customer_date > orders.order_estimated_delivery_date, 
				orders.order_id, NULL)
		) as n_delayed_deliveries,
        ROUND(COUNT(
			IF( orders.order_delivered_customer_date > orders.order_estimated_delivery_date, 
				orders.order_id, NULL)
			) / count(*) * 100, 2) as avg_delayed_deliveries
from order_items
inner join orders on orders.order_id = order_items.order_id
INNER JOIN products as p ON p.product_id = order_items.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where orders.order_status = "delivered"
group by pc.product_category_name_english
having n_items_orders >= 100
order by avg_delayed_deliveries desc;

#=============================================

select order_items.seller_id,
		count(*) as n_items_orders,
        COUNT(
			IF( orders.order_delivered_customer_date > orders.order_estimated_delivery_date, 
				orders.order_id, NULL)
		) as n_delayed_deliveries,
        ROUND(COUNT(
			IF( orders.order_delivered_customer_date > orders.order_estimated_delivery_date, 
				orders.order_id, NULL)
			) / count(*) * 100, 2) as avg_delayed_deliveries
from order_items
inner join orders on orders.order_id = order_items.order_id
INNER JOIN products as p ON p.product_id = order_items.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where orders.order_status = "delivered"
group by order_items.seller_id
having n_items_orders >= 50
order by avg_delayed_deliveries desc;
