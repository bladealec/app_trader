select *
from store_join;

-- I need to find all the distinct app names for both stores combined
-- I will import the distinct names into python and use them as a list for web scraping

SELECT DISTINCT store_name
FROM (SELECT distinct app_store_name AS store_name
	  FROM store_join
	  UNION
	  SELECT DISTINCT play_store_name AS store_name
	  FROM store_join) AS name_union;
	  
-- 16527 distinct app names


