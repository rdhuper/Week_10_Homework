-- # Homework Assignment

-- ## Installation Instructions

-- * Refer to the [installation guide](Installation.md) to install the necessary files.

-- ## Instructions

-- * 1a. Display the first and last names of all actors from the table `actor`.
USE sakila;

SELECT first_name, last_name FROM actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT (first_name, ' ', last_name) AS 'Actor Name'
FROM actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
ALTER TABLE actor
DROP COLUMN last_updated;
SELECT * FROM actor
WHERE first_name = "Joe";

-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT * FROM actor
WHERE last_name LIKE "%GEN";

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name FROM actor;
SELECT * FROM actor
WHERE last_name LIKE "%LI";

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT * FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD description BLOB;

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT  last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT  last_name, COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name)>=2;


-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO', last_name = 'WILLIAMS'
WHERE first_name = 'GROUCHO';

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name= 'GROUCHO'
WHERE first_name='HARPO';

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

--   * Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>

CREATE TABLE address_new (
  address_id INTEGER(50) NOT NULL,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id INTEGER(50) NOT NULL,
  postal_code VARCHAR(10) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  last_update DATETIME 
  );

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address,address.district,address.city_id
FROM staff
INNER JOIN address	on staff.address_id = address.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS 'Total Amount for August'
FROM staff 
INNER JOIN payment 
ON staff.staff_id = payment.staff_id
WHERE payment_date LIKE '2005-08-%'
GROUP BY  staff.first_name, staff.last_name;


-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) AS 'Total Actors'
FROM film_actor
INNER JOIN film
ON film.film_id = film_actor.film_id
GROUP BY film.title ;


-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
-- Found two ways of doing it:
-- Using JOIN:
SELECT film.title, COUNT(inventory.film_id) AS 'Total Copies'
FROM film
INNER JOIN inventory
ON film.film_id=inventory.film_id
WHERE film.title = 'HUNCHBACK IMPOSSIBLE'
GROUP BY film.film_id;

-- Using Sub-query:
SELECT  COUNT(film_id) AS 'Total Copies'
FROM inventory
WHERE film_id IN
(
SELECT film_id 
FROM film
WHERE title = 'HUNCHBACK IMPOSSIBLE'
);



-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

--   ```
--   	![Total amount paid](Images/total_payment.png)

--   ```
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS 'Total Paid'
FROM customer
INNER JOIN payment
USING (customer_id)
GROUP BY customer.customer_id
ORDER BY customer.last_name ASC;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
-- CONFIRM !!!!
SELECT title 
FROM film
WHERE title LIKE 'Q%' OR  title LIKE 'K%' AND 
language_id IN 
(
SELECT language_id 
FROM language
WHERE name = 'English'
);

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN
(
SELECT actor_id
FROM film_actor
WHERE film_id IN
(
SELECT film_id
FROM film
WHERE title = 'ALONE TRIP'
)
);


-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT CONCAT(c.first_name,' ', c.last_name) AS 'Customer Name', c.email
FROM customer as c 
JOIN address as a USING (address_id)
JOIN city USING (city_id)
JOIN country USING (country_id)
WHERE country.country= 'Canada';

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title AS 'Movies for Family'
FROM film
WHERE film_id IN
(
SELECT film_id 
FROM film_category
WHERE category_id IN
(
SELECT category_id
FROM category
WHERE name= 'Family'
)
);

-- * 7e. Display the most frequently rented movies in descending order.
SELECT film.title AS 'Movie Titles', COUNT(rental.rental_date) AS 'Number of Times Rented'
FROM film 
JOIN inventory USING (film_id)
JOIN rental USING (inventory_id)
GROUP BY film.title
ORDER BY COUNT(rental.rental_date) DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id AS 'Store ID', SUM(payment.amount) AS 'Total Sales'
FROM staff
JOIN store USING (store_id)
JOIN payment USING(staff_id)
GROUP BY store.store_id;

-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id AS 'Store ID', city.city AS 'City', country.country AS 'Country'
FROM store
JOIN address USING(address_id)
JOIN city USING(city_id)
JOIN country USING(country_id)
ORDER BY store.store_id ASC;

-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name AS 'Top 5 Genres', SUM(payment.amount) AS 'Gross Revenue'
FROM payment 
JOIN rental USING(rental_id)
JOIN inventory USING(inventory_id)
JOIN film_category USING(film_id)
JOIN category USING(category_id)
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_5_genre AS
SELECT category.name AS 'Top 5 Genres', SUM(payment.amount) AS 'Gross Revenue'
FROM payment 
JOIN rental USING(rental_id)
JOIN inventory USING(inventory_id)
JOIN film_category USING(film_id)
JOIN category USING(category_id)
GROUP BY category.name
ORDER BY SUM(payment.amount) DESC
LIMIT 5;

-- * 8b. How would you display the view that you created in 8a?
SELECT*FROM top_5_genre;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_5_genre;

-- ## Appendix: List of Tables in the Sakila DB

-- * A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

-- ```sql
-- 	'actor'
-- 	'actor_info'
-- 	'address'
-- 	'category'
-- 	'city'
-- 	'country'
-- 	'customer'
-- 	'customer_list'
-- 	'film'
-- 	'film_actor'
-- 	'film_category'
-- 	'film_list'
-- 	'film_text'
-- 	'inventory'
-- 	'language'
-- 	'nicer_but_slower_film_list'
-- 	'payment'
-- 	'rental'
-- 	'sales_by_film_category'
-- 	'sales_by_store'
-- 	'staff'
-- 	'staff_list'
-- 	'store'
-- ```

-- ## Uploading Homework

-- * To submit this homework using BootCampSpot:

--   * Create a GitHub repository.
--   * Upload your .sql file with the completed queries.
--   * Submit a link to your GitHub repo through BootCampSpot.
