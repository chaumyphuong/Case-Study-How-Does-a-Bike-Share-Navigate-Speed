# Case Study: How Does a Bike Share Navigate Speed
Author: Chau My Phuong

Date: 2025-12-03

---

# Background
**Characters and teams**
- Cyclistic: A bike-share program that features more than 5,800 bicycles and 600 docking stations. Cyclistic sets itself apart by also oering reclining bikes, hand tricycles, and cargo bikes, making bike-share more inclusive to people with disabilities and riders who can’t use a standard two-wheeled bike. The majority of riders opt for traditional bikes; about 8% of riders use the assistive options. Cyclistic users are more likely to ride for leisure, but about 30% use the bikes to commute to work each day.												
- Lily Moreno: The director of marketing and your manager. Moreno is responsible for the development of campaigns and initiatives to promote the bike-share program. These may include email, social media, and other channels.										
- Cyclistic marketing analytics team: A team of data analysts who are responsible for collecting, analyzing, and reporting data that helps guide Cyclistic marketing strategy. You joined this team six months ago and have been busy learning about Cyclistic’s mission and business goals—as well as how you, as a junior data analyst, can help Cyclistic achieve them.
- Cyclistic executive team: The notoriously detail-oriented executive team will decide whether to approve the recommended marketing program.

**About the company**

In 2016, Cyclistic launched a successful bike-share oering. Since then, the program has grown to a eet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to any other station in the system anytime.												

Until now, Cyclistic’s marketing strategy relied on building general awareness and appealing to broad consumer segments. One approach that helped make these things possible was the flexibility of its pricing plans: single-ride passes, full-day passes, and annual memberships. Customers who purchase single-ride or full-day passes are referred to as casual riders. Customers who purchase annual memberships are Cyclistic members.												

Cyclistic’s finance analysts have concluded that annual members are much more protable than casual riders. Although the pricing exibility helps Cyclistic aract more customers, Moreno believes that maximizing the number of annual members will be key to future growth. Rather than creating a marketing campaign that targets all-new customers, Moreno believes there is a solid opportunity to convert casual riders into members. She notes that casual riders are already aware of the Cyclistic program and have chosen Cyclistic for their mobility needs.												

Moreno has set a clear goal: Design marketing strategies aimed at converting casual riders into annual members. In order to do that, however, the team needs to beer understand how annual members and casual riders dier, why casual riders would buy a membership, and how digital media could aect their marketing tactics. Moreno and her team are interested in analyzing the Cyclistic historical bike trip data to identify trends.				

**In this assignment, I will produce a report with the following deliverables:**
- A clear statement of the business task
- A description of all data sources used
- Documentation of any cleaning or manipulation of data
- A summary of my analysis
- Supporting visualizations and key findings

**6-step process for approaching a case study:**
1. [Ask](#Ask)
2. [Prepare](#Prepare)
3. [Process](#Process)
4. [Analyze](#Analyze)
5. [Share](#Share)
6. [Act](#Act)

# [Ask](#Ask)
### Statement of business task											
**The goal of this case study:**

Cyclistic’s core business objective is to maximize the number of annual members (Annual Members), as key financial analysis has proven that this group is significantly more profitable than regular riders (Casual Riders).										
The data analytics team’s mission is to: Analyze historical ride data to identify unique behavioral differences between Annual Members and Casual Riders, and then design targeted marketing strategies that are likely to convert Casual Riders into Annual Members.	
 
**Three questions will guide the future marketing program:**
1.	How do annual members and casual riders use Cyclistic bikes diferently?			
2.	Why would casual riders buy Cyclistic annual memberships?											
3.	How can Cyclistic use digital media to inuence casual riders to become members?											

**Key stakeholders**
- Lily Moreno: The director of marketing												
- Marketing analytics team: A team of data analysts												
- Executive team												

# [Prepare](#Prepare)
**Description of all data sources used**

This analysis is based on Cyclistic's publicly available historical cycling trip data. Because Cyclistic is a ctional company. For the purposes of this case study, the Divvy datasets will be used. 												
- License: The data has been made available by Motivate International Inc. under this license.)												
- Source: divvy-tripdata [Link](https://divvy-tripdata.s3.amazonaws.com/index.html) (Motivate International Inc., under license).		

In this case study, Divvy_Trips_2019_Q1.csv and Divvy_Trips_2020_Q1.csv database will be used		
 
**Detailed Data Columns and Data Types**

**Divvy_Trips_2019_Q1**
| No | Column name | Data type | Purpose |
| :------- | :------ | :------- | :------- |
| 1 | trip_id | TEXT / VARCHAR |  Unique identifier of the trip |
| 2 | start_time | DATETIME |  Start time of the trip |
| 3 | end_time | DATETIME |  End time of the trip |
| 4 | bikeid | TEXT / VARCHAR |  Unique identifier of the bike |
| 5 | tripduration | INTEGER / FLOAT |  Trip duration in seconds |
| 6 | from_station_id | TEXT / VARCHAR |  Starting station ID |
| 7 |	from_station_name	| TEXT / VARCHAR |	Starting station name |
| 8	| to_station_id	| TEXT / VARCHAR	| Ending station ID |
| 9	| to_station_name |	TEXT / VARCHAR	| Ending station name |
| 10 | usertype |	TEXT / VARCHAR |	Primary classification variable |
| 11 |gender | TEXT / VARCHAR	| Gender |
| 12	| birthyear |	INTEGER |	Birth Year |
 
**Divvy_Trips_2020_Q1**
| No | Column name | Data type | Purpose |
| :-------| :------ | :------- | :------- |
| 1 | ride_id | TEXT / VARCHAR |  Unique identifier of the trip |
| 2 | rideable_type | TEXT / VARCHAR |  Type of bike or rideable used |
| 3 | started_at | DATETIME |  Start time of the trip |
| 4 | ended_at | DATETIME |  End time of the trip |
| 5 | bikeid | TEXT / VARCHAR |  Unique identifier of the bike |
| 6 | start_station_name | TEXT / VARCHAR |  Name of the starting station |
| 7 | start_station_id | TEXT / VARCHAR |  Starting station ID |
| 8 | end_station_name | TEXT / VARCHAR |  Name of the ending station |
| 9 | end_station_id | TEXT / VARCHAR |  Unique identifier for the ending station |
| 10 | start_lat | FLOAT |  Latitude of the starting point |
| 11 | start_lng | FLOAT |  Longitude of the starting point |
| 12 | end_lat | FLOAT |  Latitude of the ending point |
| 13 | end_lng | FLOAT |  Longitude of the ending point |
| 14 | member_casual |	TEXT / VARCHAR |	Primary classification variable |

**Base on ROCCC:**

The data generally adheres to the ROCCC framework (Reliable, Original, Comprehensive, Current, and Cited), but with minor limitations:

- Reliable & Original: Yes. The data is raw trip data recorded directly by the bike-share system.
- Comprehensive & Current: No. We use data in Q1 2019 and Q1 2020
- Cited: Yes. The data source is publicly cited as the operating company's data feed."

**Analysis of Potential Biases:**

- Sampling Bias
- Observer Bias
- Interpretation Bias
- Confirmation Bias

**Verify the data’s integrity:**

- Ensuring logical relationships hold true (e.g., end_time must be later than start_time).
- Filtering out trips with zero or negative duration (invalid trips) and trips exceeding 24 hours (system errors).
- Removing or addressing rows with missing values in key analytical fields (e.g., trip_id, bike_id,from_sation_id,to_station_id)

**How data answer:**

- The number of usertype or member_casual column
- The timestamps and duration each member
- The station names/IDs allow for spatial analysis

**Problems with the data?**

- Lack of Financial Data: Without explicit financial data (e.g., the cost of the casual pass purchased), the exact profitability and ROI of the proposed recommendations must be estimated rather than calculated precisely.
- Inability to Track Conversion: Since the data is de-identified (no rider IDs), it is impossible to track an individual casual rider's journey to see if they eventually convert to a member, making a true conversion funnel analysis impossible without external survey data.

**Check data using Excel:**

1. Download Divvy_Trips_2019_Q1.csv and Divvy_Trips_2020_Q1.csv of trip data.
2. Unzip the files.
3. Create a folder on your desktop and named "Divvy_tripdata".
4. Launch Excel, Data -> Get data from Text/CSV 
5. Import Divvy_Trip_2019_Q1 and Divvy_Trip_2020_Q1
6. Check errors and type
7. Load data
8. Ensure all usertype cells contain only "member" or "casual" in Divvy_Trip_2019_Q1
9. Use filter to fix errors in columns relevant to date and time
10. Create a column called ride_length. Calculate the length of each ride by subtracting the column started_at from the column ended_at (for example, =C2-B2) and format as HH:MM:SS using Format > Cells > Time > 37:30:55.
11. Create a column called day_of_week, and calculate the day of the week that each ride started using the WEEKDAY command (for example, =WEEKDAY(C2,1)) in each sheet. Format as General or as a number with no decimals, noting that 1 = Sunday and 7 = Saturday.
12. Proceed to the analyze step.

# [Process](#Process), # [Analyze](#Analyze)
I used SQL to view, check, and combine datasets, and critically, to develop the specific queries (statements) needed for the case study and perform initial statistical comparisons. Subsequently, I utilized R to re-execute or leverage the results of those SQL queries and generate comprehensive visualization reports that presented the comparison data, ultimately facilitating informed decision-making.

- **SQL to analyze:** [Bike Share Navigate Speed SQL analyze](/Bike_Share_Navigate_SQL_analyze.sql)
- **R:** [Bike Share Navigate Speed R analyze](/Bike_Share_Navigate_R_analyze.R)

# [Share](#Share)

# [Act](#Act)
**Conclusion:**
1. The Casual users have leisure, and tourism rides mostly on weekends.
2. The Annual users have commute or pragmatic rides during weekdays.

**Prediction and Strategic Recommendations**
 
Based on the demonstrated high demand for long-duration, recreational trips during the onset of the Q1 2020 shifts, the following prediction for Q2 2020 and the foreseeable future is strongly supported:
- **Prediction:** The System Will Become Leisure-Dominant
- **Sustained Casual Dominance:** The Casual segment will continue to drive ridership volume and revenue growth through the warmer months. The March tripling of casual trips is not an anomaly but a precursor to sustained high recreational demand as individuals continue to seek safe, isolated outdoor activities.
- **Increased Revenue:** The system's overall Average Revenue Per Trip will increase because the highest growth is coming from the long-duration Casual segment, which generates more fee revenue per trip.
- **Weekend Capacity Crises:** Peak demand will heavily strain fleet capacity on weekends and at stations near parks, recreational hubs, and waterfronts.

# Strategic Recommendations
- **Operations Focus:** Shift resource allocation for bike rebalancing from purely downtown/commuter routes to recreational stations during peak weekend hours (Friday evening through Sunday evening).
- **Maintenance:** Prioritize fleet maintenance and longevity, as long-duration casual use puts more wear and tear on the bikes than short commutes.
- **Pricing/Marketing:** Capitalize on the leisure market growth. Introduce flexible, short-term recreational passes or partnerships that target weekend and holiday users.
