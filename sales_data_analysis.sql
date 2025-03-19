-- 1. Membuktikan bahwa satu nama konsumen hanya memiliki satu customer id

SELECT 
  customer_name,                                      
  COUNT(DISTINCT customer_id) AS unique_customer_id   
FROM 
  `superstore.orders`                 
GROUP BY 
  customer_name                     
HAVING 
  COUNT(DISTINCT customer_id) > 1;   


-- 2. Menampilkan produk yang best selling secara kuantitas

SELECT 
  product_name,                          
  SUM(quantity) AS total_quantity_sold   
FROM 
  `superstore.orders`         
GROUP BY 
  product_name               
ORDER BY 
  total_quantity_sold DESC   
LIMIT 1;                     


-- 3. Menampilkan produk yang paling merugikan selama tahun 2017

SELECT 
  product_name,                 
  SUM(profit) AS total_profit   
FROM 
  `superstore.orders`            
WHERE 
  EXTRACT(YEAR FROM order_date) = 2017   
GROUP BY 
  product_name       
ORDER BY 
  total_profit ASC   
LIMIT 1;            


-- 4. Menentukan kota yang memiliki revenue tertinggi

SELECT 
  city,                         
  SUM(sales) AS total_revenue  
FROM 
  `superstore.orders`   
GROUP BY 
  city                 
ORDER BY 
  total_revenue DESC   
LIMIT 1;               


-- 5. Menghitung rata-rata spending per konsumen kota pada poin sebelumnya

WITH highest_revenue_city AS (   
  SELECT 
    city, 
    SUM(sales) AS total_revenue
  FROM 
    `superstore.orders` 
  GROUP BY 
    city
  ORDER BY 
    total_revenue DESC
  LIMIT 1
),

customer_spending AS (  
  SELECT 
    city,                          
    customer_id,                   
    SUM(sales) AS total_spending   
  FROM
    `superstore.orders`   
  WHERE
    city = (SELECT city FROM highest_revenue_city)  
  GROUP BY
    city, customer_id   
)

SELECT
  city,                                                       
  ROUND(AVG(total_spending),2) AS avg_spending_per_customer   
FROM
  customer_spending   
GROUP BY
  city;               


-- 6. Menampilkan tabel berisi nama-nama konsumen pada poin pertama yang memiliki spending di atas rata-rata

WITH highest_revenue_city AS (   
  SELECT 
    city,                       
    SUM(sales) AS total_revenue
  FROM 
    `superstore.orders`
  GROUP BY 
    city
  ORDER BY 
    total_revenue DESC
  LIMIT 1
),

customer_spending AS (   
  SELECT
    customer_id,                   
    customer_name,                 
    SUM(sales) AS total_spending   
  FROM 
    `superstore.orders`   
  WHERE 
    city = (SELECT city FROM highest_revenue_city)  
  GROUP BY 
    customer_id, customer_name     
),

avg_spending AS (   
  SELECT
    AVG(total_spending) AS avg_spending   
  FROM 
    customer_spending                     
)

SELECT   
  c.customer_name,                               
  ROUND(c.total_spending,2) AS total_spending     
FROM 
  customer_spending c                            
JOIN                                          
  avg_spending a                          
  ON c.total_spending > a.avg_spending    
ORDER BY c.total_spending DESC;           