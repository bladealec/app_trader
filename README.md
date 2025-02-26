# App Trader | BI Project
**NOTE: The main branch consist only of my personal work**
### Objective:
Your team has been hired by a new company called App Trader to help them explore and gain insights from apps that are made available through the Apple App Store and Android Play Store.   

### App Trader Overview:
App Trader is a broker that purchases the rights to apps from developers in order to market the apps and offer in-app purchases. The apps' developers retain all money from users purchasing the app from the relevant app store, and they retain half of the money made from in-app purchases. App Trader will be solely responsible for marketing any apps they purchase the rights to.

Unfortunately, the data for Apple App Store apps and the data for Android Play Store apps are located in separate tables with no referential integrity.


### Assumptions:

	1. App Trader will purchase the rights to apps for 10,000 times the list price of the app on the Apple App Store/Google Play Store, however the minimum price to purchase the rights to an app is $25,000. For example, a $3 app would cost $30,000 (10,000 x the price) and a free app would cost $25,000 (The minimum price). NO APP WILL EVER COST LESS THEN $25,000 TO PURCHASE.

	2. Apps earn $5000 per month on average from in-app advertising and in-app purchases regardless of the price of the app.

	3. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.

	4. For every quarter-point that an app gains in rating, its projected lifespan increases by 6 months, in other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years. Ratings should be rounded to the nearest 0.25 to evaluate an app's likely longevity.

	5. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.

 ### Deliverables:
	
	a. Develop some general recommendations about the price range, genre, content rating, or any other app characteristics that the company should target.

	b. Develop a Top 10 List of the apps that App Trader should buy based on profitability/return on investment as the sole priority.

	c. Develop a Top 4 list of the apps that App Trader should buy that are profitable but that also are thematically appropriate for next months's Pi Day themed campaign.

	d. Submit a report based on your findings. The report should include both of your lists of apps along with your analysis of their cost and potential profits. All analysis work must be done using PostgreSQL, however you may export query results to create charts in Excel for your report.

### Future Recomendations:
	
	a. (open to suggestions)

	b. Look into the total average net profit from a combination of the best prices ranges, genre, and content ratings.
		Look into install counts (review counts were considered in visualizations) 

	d. Create visualizations within a dashboard tool (PowerBi, Tabluea)



Shout out to my teammates on this project; they were awesome to bounce ideas between. 
@b-h-kim and @ckim2135
