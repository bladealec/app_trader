--NOTES:
--Code to answer delivarables is based on joining the given dataset into the 'store_join' table. The new table is created in the third querry.

--Could look into install counts (review counts where considered in visualizations) 


--Looking at given dataset
SELECT * 
FROM app_store_apps;

SELECT *
FROM play_store_apps; 

DROP TABLE store_join;
-- Joining both tables while keeping their data seperate.
--This is used to analyse both tables at once for following deliverables a, b, and c.
CREATE TABLE store_join AS (SELECT 
							
						  CASE WHEN app_store.name = play_store.name THEN 'both'
							   WHEN app_store.name IS NULL THEN 'play_store'
							   WHEN play_store.name IS NULL THEN 'app_store'
							  ELSE 'error' END AS store
							
						  ,app_store.name AS app_store_name
						  ,play_store.name AS play_store_name
						  ,app_store.size_bytes AS app_store_size_bytes
						  ,play_store.size AS play_store_size 				
						  ,app_store.price::money AS app_store_price
						  ,play_store.price::money AS play_store_price
							
						  ,CASE WHEN (app_store.price::money*10000) > 25000::money
									THEN (app_store.price::money*10000)
		    					WHEN (app_store.price::money*10000) < 25000::money 
									AND app_store.name IS NOT NULL 
									THEN 25000::money
								WHEN(app_store.price::money*10000) = 25000::money 
									THEN 25000::money
							ELSE 0::money END AS app_store_buying_price
							
	  					  ,CASE WHEN (play_store.price::money*10000) > 25000::money 
									THEN (play_store.price::money*10000)
		   						WHEN (play_store.price::money*10000) < 25000::money 
									AND play_store.name IS NOT NULL 																					THEN 25000::money
								WHEN(play_store.price::money*10000) = 25000::money 
									THEN 25000::money
							ELSE 0::money END AS play_store_buying_price
							
						  ,app_store.review_count::int AS app_store_review_count
						  ,play_store.review_count AS play_store_review_count
						  ,app_store.rating AS app_store_rating
						  ,ROUND((app_store.rating / 0.25) * 6 , 0) AS app_store_longevity
						  ,play_store.rating AS play_store_rating
						  ,ROUND((play_store.rating / 0.25) * 6 , 0) AS play_store_longevity
							
						  ,CASE WHEN app_store.rating IS NOT NULL 
									AND play_store.rating IS NOT NULL 
									THEN (app_store.rating + play_store.rating) / 2
								WHEN app_store.rating IS NOT NULL 
									AND play_store.rating IS NULL 
									THEN app_store.rating
							ELSE play_store.rating END AS avg_rating
							
--						  ,CASE WHEN app_store.content_rating = '4+' THEN 'Everyone'
--								WHEN app_store.content_rating = '9+' THEN 'Everyone 10+'	-- One could use this
--							    WHEN app_store.content_rating = '12+' THEN 'Teen'			-- for further analysis
--								WHEN app_store.content_rating = '17+' THEN 'Mature 17+'		-- on content rating.
--							ELSE 'error' END AS app_store_content_rating 	
							
						  ,app_store.content_rating AS app_store_content_rating
						  ,play_store.content_rating AS play_store_content_rating
						  ,app_store.primary_genre AS app_store_genre
						  ,play_store.category AS play_store_genre

					FROM app_store_apps AS app_store
						 FULL JOIN play_store_apps AS play_store
						 USING(name));

-- Testing new table
SELECT *
FROM store_join
LIMIT 10;


-- **DELIVERABLES**

-- a. Develop some general recommendations about the price range, genre, content rating, or any other app characteristics that the company should target.

---- Best PRICE RANGE based on sum_profitability or avg_profitability (can change in ORDER BY) **(IN PROGRESS)** (need to fix or broaden price range)
						 
SELECT app_price_range
	  ,play_price_range
	  ,(AVG(expected_net_profit::numeric))::money AS avg_net_profit
	  ,(SUM(expected_net_profit::numeric))::money AS sum_net_profit

FROM (SELECT app_store_name
 	  ,play_store_name
	  ,app_store_review_count
	  ,play_store_review_count
	  ,app_store_price
 	  ,CASE WHEN app_store_price::numeric = (0.00) THEN '$0.00'
 			WHEN app_store_price::numeric <= (3.99) THEN '$0.01 - $3.99'
 			WHEN app_store_price::numeric <= (9.99) THEN '$4.00 - $9.99'
 			WHEN app_store_price::numeric <= (49.99) THEN '$10.00 - $49.99'
  			WHEN app_store_price::numeric <= (99.99) THEN '$50.00 - $99.99'
  			WHEN app_store_price::numeric >= (100.00) THEN 'Over $100.00'
 			END AS app_price_range
	  ,play_store_price
 	  ,CASE WHEN play_store_price::numeric = (0.00) THEN '$0.00'
 			WHEN play_store_price::numeric <= (3.99) THEN '$0.01 - $3.99'
 			WHEN play_store_price::numeric <= (9.99) THEN '$4.00 - $9.99'
 			WHEN play_store_price::numeric <= (49.99) THEN '$10.00 - $49.99'
  			WHEN play_store_price::numeric <= (99.99) THEN '$50.00 - $99.99'
  			WHEN play_store_price::numeric >= (100.00) THEN 'Over $100.00'
 			END AS play_price_range
	  ,CASE WHEN store = 'both' THEN (((app_store_rating / 0.25) * 6) * 4500)::money + (((play_store_rating / 0.25) * 6) * 4500)::money - (app_store_buying_price + play_store_buying_price)::money
	  	    WHEN store = 'app_store' THEN ((((app_store_rating / 0.25) * 6 ) * 4000)::money - (app_store_buying_price))::money
			WHEN store = 'play_store' THEN ((((play_store_rating / 0.25) * 6 ) * 4000)::money - (play_store_buying_price))::money
			END AS expected_net_profit
			
FROM store_join) AS price_ranges

WHERE app_store_review_count >= 1000
	  OR play_store_review_count >= 1000
	  
GROUP BY play_price_range
		,app_price_range
		
--HAVING app_price_range = play_price_range  -- (this line presents an additional way to analyze)

ORDER BY avg_net_profit DESC;


---- Best GENRES based on sum_profitability or avg_profitability (can change in ORDER BY)
SELECT app_store_genre
	  ,play_store_genre
	  ,SUM(expected_net_profit) AS sum_net_profit
	  ,(AVG(expected_net_profit::numeric))::money AS avg_net_profit

FROM store_join
INNER JOIN
(SELECT
 	   app_store_name
 	  ,play_store_name
	  ,CASE WHEN store = 'both' THEN (((app_store_rating / 0.25) * 6) * 4500)::money + (((play_store_rating / 0.25) * 6) * 4500)::money - (app_store_buying_price + play_store_buying_price)::money
	  	    WHEN store = 'app_store' THEN ((((app_store_rating / 0.25) * 6 ) * 4000)::money - (app_store_buying_price))::money
			WHEN store = 'play_store' THEN ((((play_store_rating / 0.25) * 6 ) * 4000)::money - (play_store_buying_price))::money
			END AS expected_net_profit
			
FROM store_join) AS profits
USING(app_store_name, play_store_name)

WHERE app_store_review_count >= 1000
	  OR play_store_review_count >= 1000

GROUP BY app_store_genre
		,play_store_genre

ORDER BY avg_net_profit DESC;


--Best CONTENT RATING based on avg_profitability (can make sure the the content ratings match per game)
WITH store_join_v2 AS (SELECT 
						  CASE WHEN app_store.name = play_store.name THEN 'both'
							   WHEN app_store.name IS NULL THEN 'play_store'
							   WHEN play_store.name IS NULL THEN 'app_store'
							   ELSE 'error' END AS store
						  ,app_store.name AS app_store_name
						  ,play_store.name AS play_store_name
						  ,app_store.size_bytes AS app_store_size_bytes
						  ,play_store.size AS play_store_size 											
						  ,app_store.price::money AS app_store_price
						  ,play_store.price::money AS play_store_price
						  ,CASE WHEN (app_store.price::money*10000) > 25000::money THEN (app_store.price::money*10000)
		    					WHEN (app_store.price::money*10000) < 25000::money THEN 25000::money
								ELSE 25000::money END AS app_store_buying_price
	  					  ,CASE WHEN (play_store.price::money*10000) > 25000::money THEN (play_store.price::money*10000)
		   						WHEN (play_store.price::money*10000) < 25000::money THEN 25000::money
								ELSE 25000::money END AS play_store_buying_price
						  ,app_store.review_count::int AS app_store_review_count
						  ,play_store.review_count AS play_store_review_count
						  ,app_store.rating AS app_store_rating
						  ,ROUND((app_store.rating / 0.25) * 6 , 0) AS app_store_longevity
						  ,play_store.rating AS play_store_rating
						  ,ROUND((play_store.rating / 0.25) * 6 , 0) AS play_store_longevity
						  ,app_store.content_rating AS app_store_content_rating
						  --,CASE WHEN app_store.content_rating IS NOT NULL THEN play_store.content_rating
								--WHEN app_store.content_rating = '4+' THEN 'Everyone'
								--WHEN app_store.content_rating = '9+' THEN 'Everyone 10+'
							    --WHEN app_store.content_rating = '12+' THEN 'Teen'
								--WHEN app_store.content_rating = '17+' THEN 'Mature 17+'
								--ELSE 'error' END AS app_store_content_rating 							
						  ,play_store.content_rating AS play_store_content_rating
					      ,app_store.primary_genre AS app_store_genre
						  ,play_store.category AS play_store_genre
						  

					FROM app_store_apps AS app_store
						 FULL JOIN play_store_apps AS play_store
						 USING(name))
						 
SELECT app_store_content_rating
	  ,play_store_content_rating
	  ,SUM(expected_net_profit) AS sum_net_profit
	  ,(AVG(expected_net_profit::numeric))::money AS avg_net_profit
	  ,COUNT(*) AS amnt_of_apps


FROM store_join_v2
INNER JOIN
(SELECT
 	   app_store_name
 	  ,play_store_name
	  ,CASE WHEN store = 'both' THEN (((app_store_rating / 0.25) * 6) * 4500)::money + (((play_store_rating / 0.25) * 6) * 4500)::money - (app_store_buying_price + play_store_buying_price)::money
	  	    WHEN store = 'app_store' THEN ((((app_store_rating / 0.25) * 6 ) * 4000)::money - (app_store_buying_price))::money
			WHEN store = 'play_store' THEN ((((play_store_rating / 0.25) * 6 ) * 4000)::money - (play_store_buying_price))::money
			END AS expected_net_profit
			
FROM store_join) AS profits
USING(app_store_name, play_store_name)

WHERE (app_store_review_count + play_store_review_count) >= 1000

GROUP BY CUBE(app_store_content_rating ,play_store_content_rating)

ORDER BY avg_net_profit DESC;		
		

-- b. Develop a Top 10 List of the apps that App Trader should buy based on profitability/return on investment as the sole priority.

-- TOP 10 APPS based on profitibility ONLY (both stores' buying prices are considered)
SELECT store
 	  ,app_store_name
 	  ,play_store_name
	  ,app_store_price
 	  ,play_store_price
	  ,app_store_buying_price
	  ,play_store_buying_price
	  ,app_store_rating
	  ,play_store_rating
	  ,app_store_longevity
	  ,play_store_longevity
	  ,CASE WHEN store = 'both' THEN (((app_store_rating / 0.25) * 6) * 4500)::money + (((play_store_rating / 0.25) * 6) * 4500)::money - (app_store_buying_price + play_store_buying_price)::money
	  	    WHEN store = 'app_store' THEN ((((app_store_rating / 0.25) * 6 ) * 4000)::money - (app_store_buying_price))::money
			WHEN store = 'play_store' THEN ((((play_store_rating / 0.25) * 6 ) * 4000)::money - (play_store_buying_price))::money
			END AS expected_net_profit
			
FROM store_join

WHERE app_store_rating IS NOT NULL
	  OR play_store_rating IS NOT NULL


GROUP BY store
 	  	,app_store_name
 	  	,play_store_name
	  	,app_store_price
 	  	,play_store_price
	 	,app_store_buying_price
	 	,play_store_buying_price
	  	,app_store_rating
	  	,play_store_rating
		,app_store_longevity
		,play_store_longevity

ORDER BY expected_net_profit DESC NULLS LAST
LIMIT 10;


-- TOP 10 APPS based on profitability ONLY (only paying max price of app)
SELECT store
 	  ,app_store_name
 	  ,play_store_name
	  ,app_store_price
 	  ,play_store_price
	  ,app_store_buying_price
	  ,play_store_buying_price
	  ,app_store_rating
	  ,play_store_rating
	  ,avg_rating
	  ,app_store_longevity
	  ,play_store_longevity
	  ,CASE WHEN app_store_buying_price > play_store_buying_price THEN ((((avg_rating / 0.25) * 6 ) * 4000)::money - (app_store_buying_price))::money
			WHEN play_store_buying_price > app_store_buying_price THEN ((((avg_rating / 0.25) * 6 ) * 4000)::money - (play_store_buying_price))::money
			WHEN play_store_buying_price = app_store_buying_price THEN ((((avg_rating / 0.25) * 6 ) * 4000)::money - (play_store_buying_price))::money
			END AS expected_net_profit
			
FROM store_join

WHERE app_store_rating IS NOT NULL
	  OR play_store_rating IS NOT NULL

GROUP BY store
 	  	,app_store_name
 	  	,play_store_name
	  	,app_store_price
 	  	,play_store_price
	 	,app_store_buying_price
	 	,play_store_buying_price
	  	,app_store_rating
	  	,play_store_rating
		,avg_rating
		,app_store_longevity
		,play_store_longevity

ORDER BY expected_net_profit DESC
LIMIT 10;


-- b. COUNT() APPS with 5 star ratings and less than $2.50 store price
SELECT COUNT(*)		
FROM store_join
WHERE avg_rating::numeric <= 2.50;


-- b. TOP 10 APPS based on profitibility and a review count greater than or equal to the average review count
SELECT store
 	  ,app_store_name
	  ,play_store_name
	  ,app_store_review_count
	  ,play_store_review_count
	  ,(app_store_review_count + play_store_review_count) AS total_review_count
	  ,app_store_rating
	  ,play_store_rating
	  ,CASE WHEN store = 'both' THEN (((app_store_rating / 0.25) * 6) * 4500)::money + (((play_store_rating / 0.25) * 6) * 4500)::money - (app_store_buying_price + play_store_buying_price)::money
	  	    WHEN store = 'app_store' THEN ((((app_store_rating / 0.25) * 6 ) * 4000)::money - (app_store_buying_price))::money
			WHEN store = 'play_store' THEN ((((play_store_rating / 0.25) * 6 ) * 4000)::money - (play_store_buying_price))::money
			END AS expected_net_profit
			
FROM store_join

WHERE app_store_review_count >= (SELECT AVG(app_store_review_count)
							   	FROM store_join)
	  AND play_store_review_count >= (SELECT AVG(play_store_review_count)
									  FROM store_join)
GROUP BY store
 	  	,app_store_name
	  	,play_store_name
	  	,app_store_review_count
	 	 ,play_store_review_count
	 	 ,total_review_count
	 	 ,app_store_rating
	 	 ,play_store_rating 
		 ,expected_net_profit

ORDER BY expected_net_profit DESC
LIMIT 15;


-- c. Develop a Top 4 list of the apps that App Trader should buy that are profitable but that also are thematically appropriate for next months's Pi Day (or valentine's) themed campaign.	
		
-- Best Valentines related apps	
SELECT store
 	  ,app_store_name
 	  ,play_store_name
	  ,app_store_price
 	  ,play_store_price
	  ,app_store_buying_price
	  ,play_store_buying_price
	  ,app_store_rating
	  ,play_store_rating
	  ,app_store_review_count
	  ,play_store_review_count
	  ,CASE WHEN store = 'both' THEN (((app_store_rating / 0.25) * 6) * 4500)::money + (((play_store_rating / 0.25) * 6) * 4500)::money - (app_store_buying_price + play_store_buying_price)::money
	  	    WHEN store = 'app_store' THEN ((((app_store_rating / 0.25) * 6 ) * 4000)::money - (app_store_buying_price))::money
			WHEN store = 'play_store' THEN ((((play_store_rating / 0.25) * 6 ) * 4000)::money - (play_store_buying_price))::money
			END AS expected_net_profit
			
FROM store_join

WHERE app_store_name ILIKE '%romance%'
      OR play_store_name ILIKE '%romance%'
      OR app_store_name ILIKE '%love%'
      OR play_store_name ILIKE '%love%'
      OR app_store_name ILIKE '%drama%'
      OR play_store_name ILIKE '%drama%'
      OR app_store_name ILIKE '%dating%'
      OR play_store_name ILIKE '%dating%'
      OR app_store_name ILIKE '%wife%'
      OR play_store_name ILIKE '%wife%'
      OR app_store_name ILIKE '%husband%'
      OR play_store_name ILIKE '%husband%'
      OR app_store_name ILIKE '%boyfriend%'
      OR play_store_name ILIKE '%boyfriend%'
      OR app_store_name ILIKE '%relation%'
      OR play_store_name ILIKE '%relation%'
      OR app_store_name ILIKE '%relationship%'
      OR play_store_name ILIKE '%relationship%'
	  
GROUP BY store
 	  	,app_store_name
 	  	,play_store_name
	  	,app_store_price
 	  	,play_store_price
	 	,app_store_buying_price
	 	,play_store_buying_price
	  	,app_store_rating
	  	,play_store_rating
		,app_store_review_count
		,play_store_review_count

HAVING app_store_rating IS NOT NULL
	   OR play_store_rating IS NOT NULL
	   AND (app_store_review_count >= (SELECT AVG(app_store_review_count)
							    FROM store_join)
	        OR play_store_review_count >= (SELECT AVG(play_store_review_count)
								 FROM store_join))

ORDER BY expected_net_profit DESC
LIMIT 15;

--"Tom's Love Letters" and "Tom Loves Angela" seem to be the best choice based on my filters
--I personally like "Cougar Dating & Life Style App for Mature Women"


-- Best Pi DAY related apps	
SELECT store
 	  ,app_store_name
 	  ,play_store_name
	  ,app_store_price
 	  ,play_store_price
	  ,app_store_buying_price
	  ,play_store_buying_price
	  ,app_store_rating
	  ,play_store_rating
	  ,app_store_review_count
	  ,play_store_review_count
	  ,CASE WHEN store = 'both' THEN (((app_store_rating / 0.25) * 6) * 4500)::money + (((play_store_rating / 0.25) * 6) * 4500)::money - (app_store_buying_price + play_store_buying_price)::money
	  	    WHEN store = 'app_store' THEN ((((app_store_rating / 0.25) * 6 ) * 4000)::money - (app_store_buying_price))::money
			WHEN store = 'play_store' THEN ((((play_store_rating / 0.25) * 6 ) * 4000)::money - (play_store_buying_price))::money
			END AS expected_net_profit
			
FROM store_join

WHERE app_store_name ILIKE '%math%'
      OR play_store_name ILIKE '%math%'
      OR app_store_name ILIKE '%algebra%'
      OR play_store_name ILIKE '%algebra%'
      OR app_store_name ILIKE '%geometry%'
      OR play_store_name ILIKE '%geometry%'
      OR app_store_name ILIKE '%calculus%'
      OR play_store_name ILIKE '%calculus%'
      OR app_store_name ILIKE '%physics%'
      OR play_store_name ILIKE '%physics%'
      OR app_store_name ILIKE '%trigonometry%'
      OR play_store_name ILIKE '%trigonomety%'
      OR app_store_name ILIKE '% pi %'
      OR play_store_name ILIKE '% pi %'
      OR app_store_name ILIKE '%number%'
      OR play_store_name ILIKE '%number%'
      OR app_store_name ILIKE '%school%'
      OR play_store_name ILIKE '%school%'
	  
GROUP BY store
 	  	,app_store_name
 	  	,play_store_name
	  	,app_store_price
 	  	,play_store_price
	 	,app_store_buying_price
	 	,play_store_buying_price
	  	,app_store_rating
	  	,play_store_rating
		,app_store_review_count
		,play_store_review_count

HAVING app_store_rating IS NOT NULL
	   OR play_store_rating IS NOT NULL
	   AND(app_store_review_count >= (SELECT AVG(app_store_review_count)
							    FROM store_join)
	       OR play_store_review_count >= (SELECT AVG(play_store_review_count)
								 FROM store_join))
ORDER BY expected_net_profit DESC
LIMIT 15;