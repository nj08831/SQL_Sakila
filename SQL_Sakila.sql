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
WHERE country in ('Bangladesh', 'China', 'Afghanistan') 
;

#3a. You want to keep a description of each actor. 
#You don't think you will be performing queries on a description, 
#so create a column in the table actor named description and use the data type BLOB 
#(Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;

SELECT * 
FROM actor
LIMIT 10
;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
#Delete the description column.
ALTER TABLE actor
DROP description;

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
HAVING num_lastnames >1
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
    first_name = 'HARPO',
	last_update = '2019-01-24 15:05:00'
WHERE
    actor_id = 172 
   
;
    
SELECT *
from actor
WHERE last_name = 'WILLIAMS'

#Checked that timestamp was Auto_update, so moving forward, using Autoupdate
SHOW COLUMNS FROM actor;

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
#if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET 
    first_name = 'GROUCHO'
WHERE
    last_name = 'WILLIAMS'
;

SELECT *
FROM actor
WHERE first_name = 'HARPO'

# I made a mistake, I didn't use the actor_id and attempted to revert my error with ROLLBACK. I Was unsuccessful.
# I made any WILLIAMS last name into a first name of GROUCHO.
# not clear why the ROLLBACK option would not work, set the Datbase option in Workbench to Rollback, perhaps too late

ROLLBACK;

SELECT *
FROM actor
WHERE first_name = 'HARPO'
;
#5a. You cannot locate the schema of the address table. 
#Which query would you use to re-create it?

USE sakila;

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
film as t
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




