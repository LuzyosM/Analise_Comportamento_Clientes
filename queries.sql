--Q1. Qual é a receita total gerada por clientes do sexo masculino vs. feminino?
select gender, SUM(purchase_amount) as revenue
from customer
group by gender

--Q2. Quais clientes usaram um desconto mas ainda assim gastaram mais do que o valor médio de compra?
select customer_id, purchase_amount 
from customer 
where discount_applied = 'Yes' and purchase_amount >= (select AVG(purchase_amount) from customer)

--Q3. Quais são os 5 produtos com a maior média de avaliação?
select item_purchased, round(avg(review_rating::numeric),2) as "Average Product Rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5

--Q4. Compare os valores médios de compra entre Envio Padrão e Envio Expresso.
select shipping_type, 
ROUND(AVG(purchase_amount),2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type;

--Q5. Os clientes assinantes gastam mais? Compare o gasto médio e a receita total 
--entre assinantes e não-assinantes.
SELECT subscription_status,
       COUNT(customer_id) AS total_customers,
       ROUND(AVG(purchase_amount),2) AS avg_spend,
       ROUND(SUM(purchase_amount),2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue,avg_spend DESC;

--Q6. Quais 5 produtos têm a maior porcentagem de compras com descontos aplicados?
SELECT item_purchased,
       ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS discount_rate
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;


--Q7. Segmente os clientes em Novos, Retornando e Fiéis com base no número total 
--de compras anteriores, e mostre a contagem de cada segmento.
with customer_type as (
SELECT customer_id, previous_purchases,
CASE 
    WHEN previous_purchases = 1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
    ELSE 'Loyal'
    END AS customer_segment
FROM customer)

select customer_segment,count(*) AS "Number of Customers" 
from customer_type 
group by customer_segment;


--Q8. Quais são os 3 produtos mais comprados dentro de cada categoria?
WITH item_counts AS (
    SELECT category,
           item_purchased,
           COUNT(customer_id) AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
    FROM customer
    GROUP BY category, item_purchased
)
SELECT item_rank,category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <=3;

--Q9. Os clientes que são compradores recorrentes (mais de 5 compras anteriores) também têm maior probabilidade de assinar?
SELECT subscription_status,
       COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

--Q10. Qual é a contribuição de receita de cada faixa etária?
SELECT 
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue desc;

