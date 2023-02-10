WITH both_stores AS 	(SELECT name,  
									CASE 	WHEN as_review_count IS NOT NULL AND ps_review_count IS NOT NULL THEN 'both'
											ELSE 'one' END AS store_1,
									(COALESCE(as_review_count,0) + COALESCE(ps_review_count,0)) AS total_reviews,
									CASE 	WHEN as_rating IS NOT NULL AND ps_rating IS NULL THEN as_rating
											WHEN as_rating IS NULL AND ps_rating IS NOT NULL THEN ps_rating
											WHEN as_rating IS NULL and ps_rating IS NULL THEN 0
											ELSE ROUND(((as_rating*as_review_count) + (ps_rating*ps_review_count))/(as_review_count + ps_review_count),1) END AS overall_rating,
									as_price, ps_price,
									CASE 	WHEN as_review_count IS NOT NULL AND ps_review_count IS NOT NULL THEN 'both'
											WHEN as_review_count IS NOT NULL THEN 'as'
											ELSE 'ps' END AS store_2,
									CASE 	WHEN as_price IS NULL THEN ps_price
						 					WHEN ps_price IS NULL THEN as_price
						 					WHEN as_price >= ps_price THEN as_price
						 					ELSE ps_price END AS highest_price,
						 			CASE	WHEN CONCAT(as_genre, ps_genre) ILIKE '%games%' OR CONCAT(as_genre, ps_genre) ILIKE '%entertainment%' OR CONCAT(as_genre, ps_genre) ILIKE '%casino%' OR CONCAT(as_genre, ps_genre) ILIKE '%racing%' OR CONCAT(as_genre, ps_genre) ILIKE '%card%' OR CONCAT(as_genre, ps_genre) ILIKE '%board%' OR name ILIKE '%game%' OR CONCAT(as_genre, ps_genre) ILIKE '%strategy%' OR CONCAT(as_genre, ps_genre) ILIKE '%puzzle%' OR CONCAT(as_genre, ps_genre) ILIKE '%action%' OR CONCAT(as_genre, ps_genre) ILIKE '%comics%' OR CONCAT(as_genre, ps_genre) ILIKE '%role playing%' OR CONCAT(as_genre, ps_genre) ILIKE '%arcade%' OR CONCAT(as_genre, ps_genre) ILIKE '%sports%' THEN 'games_entertainment'
						 					WHEN CONCAT(as_genre, ps_genre) ILIKE '%health%' OR CONCAT(as_genre, ps_genre) ILIKE '%fitness%' THEN 'health_fitness'
						 					WHEN CONCAT(as_genre, ps_genre) ILIKE '%education' THEN 'education'
						 					WHEN CONCAT(as_genre, ps_genre) ILIKE '%lifestyle%' OR CONCAT(as_genre, ps_genre) ILIKE '%shopping%' THEN 'lifestyle_shopping'
						 					WHEN CONCAT(as_genre, ps_genre) ILIKE '%food%' OR CONCAT(as_genre, ps_genre) ILIKE '%drink%' THEN 'food_drink'
						 					WHEN CONCAT(as_genre, ps_genre) ILIKE '%photo%' OR CONCAT(as_genre, ps_genre) ILIKE '%video%' THEN 'photo_video'
						 					WHEN CONCAT(as_genre, ps_genre) ILIKE '%productivity%' OR CONCAT(as_genre, ps_genre) ILIKE '%tool%' THEN 'productivity'
						 					WHEN CONCAT(as_genre, ps_genre) ILIKE '%social%' OR CONCAT(as_genre, ps_genre) ILIKE '%communication%' THEN 'social_communication'
						 					WHEN CONCAT(as_genre, ps_genre) ILIKE '%education%' THEN 'education'
						 					WHEN CONCAT(as_genre, ps_genre) ILIKE '%travel%' OR CONCAT(as_genre, ps_genre) ILIKE '%local%' THEN 'travel_local'
						 					WHEN CONCAT(as_genre, ps_genre) ILIKE '%business%' OR CONCAT(as_genre, ps_genre) ILIKE '%finance%' THEN 'business_finance'
						 					WHEN CONCAT(as_genre, ps_genre) ILIKE '%book%' OR CONCAT(as_genre, ps_genre) ILIKE '%reference%' OR CONCAT(as_genre, ps_genre) ILIKE '%weather%' OR CONCAT(as_genre, ps_genre) ILIKE '%news%' THEN 'book_news_reference'
						 					ELSE CONCAT(as_genre, ps_genre) END AS genre

							FROM	(SELECT name, ROUND(AVG(rating::numeric),1) AS as_rating, ROUND(AVG(review_count::numeric)) AS as_review_count, price::money AS as_price, content_rating AS as_content, primary_genre AS as_genre
									FROM app_store_apps
									GROUP BY name, price, content_rating, primary_genre) AS app_store

								FULL JOIN

									(SELECT name, ROUND(AVG(rating::numeric),1) AS ps_rating, ROUND(AVG(review_count::numeric)) AS ps_review_count, price::money AS ps_price, content_rating AS ps_content, genres AS ps_genre, install_count AS ps_install_count
									FROM play_store_apps
									GROUP BY name, price, content_rating, genres, install_count) AS play_store
								USING (name)
							GROUP BY name, as_genre, ps_genre, as_review_count, ps_review_count, as_rating, ps_rating, as_price, ps_price)

								
								
SELECT 	name, genre, store_1, total_reviews, overall_rating,
		-- monthly_netincome 4000 for apps in one store, 9000 for apps in both
		CASE WHEN store_1 = 'both' THEN 9000
		ELSE 4000 END AS monthly_netincome,
		-- 1 star = 2 years or (2 * 12) months
		ROUND((overall_rating * 2)*12) AS longevity_m,
		-- Lifetime income = longevity_m * monthly_netincome
		ROUND((overall_rating * 2)*12) * 	(CASE WHEN store_1 = 'both' THEN 9000::money
											ELSE 4000::money END) AS lifetime_income,
		-- calculation of purchase_price (app price * 10000 or 25000, whichever is bigger)									
		CASE WHEN	highest_price*10000 < 25000::money THEN 25000::money
			ELSE	highest_price*10000 END AS purchase_price,
		-- lifetime_income - purchase_price = net_profit	
			ROUND((overall_rating * 2)*12) * 	(CASE WHEN store_1 = 'both' THEN 9000::money
												ELSE 4000::money END)	
				-
			(CASE WHEN	highest_price*10000 < 25000::money THEN 25000::money
				ELSE	highest_price*10000 END) AS net_profit
		
FROM both_stores

GROUP BY name, genre, store_1, total_reviews, overall_rating, highest_price
ORDER BY net_profit DESC
LIMIT 10;