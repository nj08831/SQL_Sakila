# Define database that will be used
USE sakila;

# 1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name
FROM actor
;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, ' ', last_name) AS actor_name
FROM actor
;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE '%joe%'
;

#2b. Find all actors whose last name contain the letters GEN:
SELECT CONCAT(first_name, ' ', last_name) AS actor_name
FROM actor
WHERE last_name LIKE '%gen%'
;

#2c. Find all actors whose last names contain the letters LI. 
#This time, order the rows by last name and first name, in that order
SELECT CONCAT(first_name, ' ', last_name) AS actor_name
FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name
;

#2d. Using IN, display the country_id and country columns of the following countries: 
#Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Bangladesh', 'China', 'Afghanistan') 
;

#3a. You want to keep a description of each actor. 
#You don't think you will be performing queries on a description, 
#so create a column in the table actor named description and use the data type BLOB 
#(Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;

#QAing the change
SELECT * 
FROM actor
LIMIT 10
;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
#Delete the description column.
ALTER TABLE actor
DROP description;

#QAing the change
SELECT *
FROM actor
LIMIT 10
;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) as num_lastnames
FROM actor
GROUP BY last_name
ORDER BY num_lastnames DESC
;

#4b. List last names of actors and the number of actors who have that last name, 
#but only for names that are shared by at least two actors
SELECT last_name, count(last_name) as num_lastnames
FROM actor
GROUP BY last_name
HAVING num_lastnames > 1
ORDER BY num_lastnames DESC
;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
#Write a query to fix the record.
SELECT *
FROM actor
WHERE first_name = 'GROUCHO'
;

UPDATE actor
SET 
    first_name = 'HARPO'
WHERE
    actor_id = 172 
   
;

#QAing the change
SELECT *
from actor
WHERE last_name = 'WILLIAMS'
;

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
#if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET 
    first_name = 'GROUCHO'
WHERE
    actor_id = 172
;

#QAing the change
SELECT *
FROM actor
WHERE first_name = 'HARPO'
;

SELECT * FROM actor WHERE actor_id = 172;

#5a. You cannot locate the schema of the address table. 
#Which query would you use to re-create it?
SHOW CREATE TABLE address;
# I prefer this approach to seeing the Schema of a Table
SHOW COLUMNS FROM address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
#Use the tables staff and address:

#QAing the number of staff in the staff file
SELECT * FROM staff;

SELECT s.address_id, s.first_name, s.last_name, a.address 
FROM staff AS s
LEFT JOIN 
address AS a 
ON s.address_id = a.address_id
;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
#Use tables staff and payment.

#reviewing the payment table and the datetime
SELECT * FROM payment LIMIT 10;
SHOW COLUMNS FROM payment;

SELECT CONCAT(s.first_name, ' ', s.last_name) AS staffer, SUM(p.amount) as sum_amt, YEAR(p.payment_date) AS pay_year
FROM staff as s
JOIN
payment AS p
ON s.staff_id = p.staff_id AND
YEAR(p.payment_date) = 2005 and MONTH(p.payment_date) = 8
GROUP BY staffer
;

# QAing the result
SELECT staff_id, COUNT(staff_id) FROM payment GROUP BY staff_id;
SELECT staff_id FROM payment;
;

#6c. List each film and the number of actors who are listed for that film. 
#Use tables film_actor and film. Use inner join.
SELECT film_id, title FROM film;
SELECT * FROM film_actor ORDER BY film_id, actor_id;

SELECT TEMP.title, count(TEMP.actor_id) AS num_actors
FROM
(
SELECT f.film_id, f.title, a.actor_id
FROM film AS f
INNER JOIN
film_actor AS a
ON f.film_id = a.film_id
#GROUP BY f.film_id
#ORDER BY num_actors DESC

) TEMP
GROUP BY TEMP.title
ORDER BY num_actors DESC
;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
# Identifying the number of films using film_id identification for simplicity
SELECT Count(film_id) FROM inventory WHERE film_id = 439;
SELECT * FROM film WHERE title = 'Hunchback Impossible';

SELECT COUNT(i.film_id), t.title 
FROM inventory AS i
INNER JOIN
film AS t
ON t.film_id = i.film_id
WHERE t.title = 'Hunchback Impossible'

;

#6e. Using the tables payment and customer and the JOIN command, 
#list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer_id, sum(amount) as sum_payment FROM payment GROUP BY customer_id;

SELECT c.first_name, c.last_name, SUM(p.amount) AS sum_payment
FROM payment AS p
JOIN 
customer AS c
ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name
;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT * FROM language LIMIT 10;

SELECT f.title AS english_movies_k_q
FROM film AS f
JOIN
language AS l
ON f.language_id = l.language_id
WHERE (f.title LIKE 'Q%' OR f.title LIKE 'K%' ) AND l.name = 'English'
ORDER BY f.title

;

#7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT TEMP.actor_id, act.first_name, act.last_name
FROM

(
SELECT a.actor_id, a.film_id, f.title
FROM film_actor AS a
JOIN
film as f
ON f.film_id = a.film_id
WHERE f.title = 'Alone Trip'
) TEMP
JOIN actor AS act
ON TEMP.actor_id = act.actor_id
;

#7c. You want to run an email marketing campaign in Canada, for which you will need the names 
#and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT *  FROM customer ;  #address_id
SELECT * FROM address LIMIT 10;   #address_id, city_id
SELECT * FROM city ;  #city_id, country_id
SELECT * FROM country LIMIT 10;  #country_id (to country)

SELECT cust.first_name, cust.last_name, cust.email, country.country, country.country_id, c.city_id
FROM customer AS cust
JOIN address AS a ON a.address_id = cust.address_id
JOIN city as c    ON c.city_id    = a.city_id
JOIN country as country  ON country.country_id  = c.country_id
WHERE country.country = 'Canada'
;

SELECT s.store_id, country.country, country.country_id, c.city_id
FROM store AS s
JOIN address AS a ON a.address_id = s.address_id
JOIN city AS c    ON c.city_id    = a.city_id
JOIN country AS country  ON country.country_id  = c.country_id

WHERE country.country = 'Canada'
;

# BELOW ARE QA efforts to confirm the above sql data is accurate
SELECT * FROM customer WHERE store_id = 1;

SELECT c.city_id, c.city, country.country 
FROM city as c
JOIN country AS country ON c.country_id = country.country_id;

SELECT cust.first_name, cust.last_name, cust.email, a.city_id
FROM customer AS cust
JOIN address AS a ON a.address_id = cust.address_id
WHERE a.city_id IN (179,196,300,313,383,430,565)
;

#7d. Sales have been lagging among young families, and you wish to target all family movies for a 
#promotion. Identify all movies categorized as family films.
SELECT rental_id, count(customer_id) 
FROM payment 
GROUP BY rental_id;  # category_id (has name)  Family = category_id 8
SELECT film_id FROM film_category WHERE category_id = 8;  #category_id & film_id
SELECT * FROM film LIMIT 10;  #title, film_id

SELECT f.title, f.film_id, c.name
FROM
film AS f
JOIN film_category AS fc ON fc.film_id = f.film_id
JOIN category      AS c ON c.category_id = fc.category_id
WHERE c.name = 'Family'
;


#7e. Display the most frequently rented movies in descending order.
SELECT * FROM payment; #rental_id
SELECT * FROM rental;  # customer_id (count these), rental_date, inventory_id
SELECT * FROM inventory LIMIT 10; #inventory_id, film_id 
SELECT * FROM film LIMIT 10;  #title, film_id


SELECT  f.title , f.film_id, month(r.rental_date) as month_rented,  COUNT(f.film_id) AS num_rentals
FROM payment AS p
JOIN rental AS r ON p.rental_id = r.rental_id
JOIN inventory AS i ON i.inventory_id = r.inventory_id
JOIN film AS f ON f.film_id = i.film_id
WHERE month(r.rental_date)  = 8
GROUP BY  month_rented, f.film_id
ORDER BY num_rentals DESC

#ORDER BY num_rents DES
;


#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM store ;  #store_id
SELECT * FROM customer;  #customer_id, store_id
SELECT * FROM payment; #customer_id, amount

SELECT s.store_id, concat('$', format(sum(p.amount),2)) as tot_store_sales
FROM payment AS p
JOIN customer AS c ON c.customer_id = p.customer_id
JOIN store AS s ON s.store_id = c.store_id
GROUP BY s.store_id
;

#QAing the resulting amounts (this should equal the sum of each store sales)
SELECT sum(amount) from payment;

# Need to know in USD? So, need to know Store's Country location to convert the money
# Payment has customer_id, customer_id, address_id is in customer
# address_id is in address, city_id is in City, and country is in country


#7g. Write a query to display for each store its store ID, city, and country.
SELECT  s.store_id ,c.city, country.country #, country.country,
FROM store AS s
INNER JOIN address as a ON a.address_id = s.address_id
INNER JOIN city    as c ON c.city_id = a.city_id
INNER JOIN country as country ON country.country_id = c.country_id
;

#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: 
#category, film_category, inventory, payment, and rental.)
USE sakila;
SELECT * from category LIMIT 10;  #genres are found here - NAME, category_id
SELECT * from film_category LIMIT 10;  # film_id to category_id is found here
SELECT * from inventory LIMIT 10;  #film_id to inventory_id and store_id is here
SELECT * from rental LIMIT 10; #rental_id , rental_date, and inventory_id is here
SELECT * from payment ; #payment and rental_id is found here

####  Working thru the logic - NAGA assisted with confirming this was accurate
SELECT  c.name, SUM(p.amount) AS sum_amount
FROM category AS c
JOIN film_category AS fc ON fc.category_id = c.category_id
JOIN inventory AS i ON i.film_id = fc.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
JOIN payment AS p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY sum_amount DESC
LIMIT 5
;

####

#8a. In your new role as an executive, you would like to have an easy way of 
#viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. 

CREATE VIEW `Top_5_Gross_Rev_Genres` AS 
SELECT  c.name, SUM(p.amount) AS sum_amount
FROM category AS c
JOIN film_category AS fc ON fc.category_id = c.category_id
JOIN inventory AS i ON i.film_id = fc.film_id
JOIN rental AS r ON r.inventory_id = i.inventory_id
JOIN payment AS p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY sum_amount DESC
LIMIT 5
;

#8b. How would you display the view that you created in 8a?
SELECT * FROM `Top_5_Gross_Rev_Genres`;

#8c. You find that you no longer need the view top_five_genres. 
#Write a query to delete it.

DROP VIEW `Top_5_Gross_Rev_Genres`;

 