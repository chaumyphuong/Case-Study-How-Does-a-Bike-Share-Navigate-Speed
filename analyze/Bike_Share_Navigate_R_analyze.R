#1.Install packages and library

install.packages("tidyverse")
library(tidyverse)  #helps wrangle data
library(lubridate)  #helps wrangle date attributes
library(ggplot2)  #helps visualize data
library(dplyr) #helps clean data
library(tidyr) #helps clean data
install.packages("geosphere") #for trip duration calculation
library(geosphere)

#2.Load data

q1_2019 <- read_csv("/cloud/project/Divvy_tripdata/Divvy_Trips_2019_Q1.csv")
q1_2020 <- read_csv("/cloud/project/Divvy_tripdata/Divvy_Trips_2020_Q1.csv")

#3.Data check

#Head
head(q1_2019)
head(q1_2020)
#Str
str(q1_2019)
str(q1_2020)
#colnames
colnames(q1_2019)
colnames(q1_2020)
#glimpse
glimpse(q1_2019)
glimpse(q1_2020)
#View
view(q1_2019)
view(q1_2020)


#4. Clean Up and Add Data for Analysis

#Rename 2019 columns to match 2020 schema

q1_2019_clean <- q1_2019 %>%
  select(
    ride_id = trip_id,
    started_at = start_time,
    ended_at = end_time,
    start_station_name = from_station_name,
    end_station_name = to_station_name,
    member_casual = usertype,
    ride_length,
    day_of_week,
    trip_duration = tripduration
  ) %>%
  # Convert date time
  mutate(
    started_at = dmy_hm(started_at),
    ended_at = dmy_hm(ended_at),
  ) %>% 
  # Convert trip_id
  mutate(
    ride_id = as.character(ride_id)
  )

view(q1_2019_clean)

#Convert and add columns to match

q1_2020_clean <- q1_2020 %>%
  select(
    ride_id,
    started_at,
    ended_at,
    start_station_name,
    end_station_name,
    member_casual,
    ride_length,
    day_of_week,
    start_lng, 
    start_lat, 
    end_lng, 
    end_lat
  ) %>% 
  # Convert date time
  mutate(
    started_at = dmy_hms(started_at),
    ended_at = dmy_hms(ended_at)
    ) %>% 
  # Add trip_duration
  mutate(
    trip_duration = distGeo(matrix(c(start_lng,start_lat),ncol=2),matrix(c(end_lng,end_lat),ncol=2))
  )

view(q1_2020_clean)

#Combine data

all_trips <- bind_rows(q1_2019_clean, q1_2020_clean)
view (all_trips)

#Clean memory

rm(q1_2019,q1_2019_clean,q1_2020_clean)

#Clean the final table

all_trips_clean <- all_trips %>%
  # Filter out negative duration trips
  filter(ride_length > 0) %>%
  # Add necessary time components for grouping
  mutate(
    trip_year = year(started_at),
    trip_month = month(started_at, label = TRUE, abbr = FALSE),
    # Recalculate day_of_week just in case the source column was numeric
    day_of_week = wday(started_at, label = TRUE, abbr = FALSE, week_start = 1)
  )

view (all_trips_clean)
rm(all_trips)

# Descriptive analysis

#A. Summary by User Type and Year

summary_by_year <- all_trips_clean %>%
  group_by(trip_year, member_casual) %>%
  summarise(
    total_trips = n()
  )

print(summary_by_year)

#B. Overall User Summary

overall_user <- all_trips_clean %>%
  group_by(member_casual) %>%
  summarise(
    total_rides = n(),
    avg_ride_length = mean(ride_length),
    longest_trip_min = max(ride_length)
  ) %>%
  arrange(desc(total_rides))

print(overall_user)

#C. Day-of-Week Trend

summary_by_weekday <- all_trips_clean %>%
  group_by(member_casual, day_of_week) %>%
  summarise(
    total_trips = n()
  ) %>%
  # Pivot the data for a clean side-by-side comparison
  pivot_wider(names_from = member_casual, values_from = total_trips) %>%
  ungroup()

print(summary_by_weekday)

#D. Monthly Trend

summary_by_month <- all_trips_clean %>%
  group_by(member_casual, trip_month) %>%
  summarise(
    total_rides = n()
  ) %>%
  pivot_wider(names_from = member_casual, values_from = total_rides) %>%
  ungroup()

print(summary_by_month)

#E. Distance trend by day of week

summary_day_distance <- all_trips_clean %>%
  group_by(day_of_week,member_casual) %>%
  summarise(distance_of_ride = mean(trip_duration),) %>%
  arrange(day_of_week)

print(summary_day_distance)

#F. Distance trend by day of week

summary_month_distance <- all_trips_clean %>%
  group_by(trip_month,member_casual) %>%
  summarise(distance_of_ride = mean(trip_duration),) %>%
  arrange(trip_month)

print(summary_month_distance)

# Share {#Share}

#A. Total Trips by Year and User Type

yearly_comparison_chart <- summary_by_year %>%
  ggplot(aes(x = trip_year, y = total_trips, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Usertype Comparison: 2019 vs. 2020",
    x = "Year",
    y = "Total Trips",
    fill = "Rider Type"
  ) +
  theme_minimal()

print(yearly_comparison_chart)

#Key Findings:
#- In 2019, casual riders (red) made only ~40,000 trips, while members (cyan) made ~370,000 trips — members dominated usage (~90% of total trips).
#- In 2020, total trips increased dramatically. Member trips rose to ~410,000 (+10–15%), but casual rider trips exploded to ~70,000 (nearly 2x higher than 2019).
#- The share of casual riders grew significantly from ~10% in 2019 to ~15% in 2020.
#- Overall ridership grew by ~25–30% from 2019 to 2020, driven mainly by a surge in casual users.
#Conclusion: 2020 saw a major shift toward casual rider growth, likely influenced by the COVID-19 pandemic (people avoiding subscriptions or using bikes for recreation/exercise).

#B. Day-of-Week Trend

weekday_trend_chart <- all_trips_clean %>%
  group_by(member_casual, day_of_week) %>%
  summarise(total_trips = n()) %>%
  ggplot(aes(x = day_of_week, y = total_trips, fill = member_casual)) +
  geom_bar(position = "dodge",stat = "identity")+
  labs(
    title = "Membership by Day of Week",
    x = "Day of Week",
    y = "Total Trips",
    color = "Rider Type"
  ) +
  theme_minimal()

print(weekday_trend_chart)

#Key Findings:
#- Members (cyan) ride consistently high every day, peaking on Tuesday (~180,000 trips) and staying strong through Thursday.
#- Casual riders (red) have very low weekday usage (~10–20k) but spike dramatically on weekends, especially Saturday (~60,000).
#- Weekend (Sat–Sun) is when casuals contribute the most; Saturday casual trips are ~3–4× higher than weekdays.
#Conclusion: Members use the system primarily for commuting (weekday pattern), while casuals use it mostly for leisure (weekend pattern).

#C. Monthly Trend

monthly_trend_chart <- all_trips_clean %>%
  group_by(member_casual, trip_month) %>%
  summarise(total_trips = n()) %>%
  ggplot(aes(x = trip_month, y = total_trips, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Monthly Usage Trend",
    x = "Month",
    y = "Total Trips",
    fill = "Rider Type"
  ) +
  theme_minimal()

print (monthly_trend_chart)

#Key Findings:
#- January and February: Member trips ~230–250k, casual ~30–40k (members ~85–90% of total).
#- March: Huge surge — total trips jump to ~300k+, with casual trips skyrocketing to ~70–80k (almost double February), while member trips stay relatively flat or slightly increase.
#- Casual share jumps from ~12–15% in Jan–Feb to ~25%+ in March.
#Conclusion: March 2020 shows a dramatic increase in casual ridership, very likely due to early COVID-19 lockdowns — people using bikes for exercise/outdoor activity when gyms and public transit were avoided.

#D. Average Day-of-Week Trend 

avg_weekday_trend_chart <- all_trips_clean %>%
  group_by(member_casual, day_of_week) %>%
  summarise(average_ride_length=mean(ride_length)) %>%
  ggplot(aes(x = day_of_week, y = average_ride_length, fill = member_casual)) +
  geom_bar(position = "dodge",stat = "identity")+
  labs(
    title = "Average membership by Day of Week",
    x = "Day of Week",
    y = "Total Trips",
    color = "Rider Type"
  ) +
  theme_minimal()

print(avg_weekday_trend_chart)

#Key Findings:
#- Casual riders (red): Clear weekend peak (Saturday ~2,600, Sunday ~2,500 avg daily trips), lowest on Wednesday (~2,100).
#- Members (cyan): Much lower average daily trips (~500–700), relatively flat across the week, slight dip mid-week.
#- Casuals average 4–5× more daily trips than members on weekends, but similar on weekdays.
#Conclusion: When looking at per-day averages, casual riders dominate weekend usage by a wide margin; members are consistent but low-volume daily user

#E. Average Monthly Trend (Bar Chart, showing the March spike)

avg_monthly_trend_chart <- all_trips_clean %>%
  group_by(member_casual, trip_month) %>%
  summarise(average_ride_length = mean(ride_length)) %>%
  ggplot(aes(x = trip_month, y = average_ride_length, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(
    title = "Average Monthly Usage Trend",
    x = "Month",
    y = "Total Trips",
    fill = "Rider Type"
  ) +
  theme_minimal()

print(avg_monthly_trend_chart)

#Key Findings:

#- Casual riders (red): Steady increase from ~2,400 avg daily trips in January to ~2,600 in March.
#- Members (cyan): Very low and stable (~600–700 avg daily trips) across all three months.
#- In March, casual average daily trips are ~4× higher than members.
#Conclusion: Even on an average daily basis, casual riders significantly outpace members in early 2020, with a clear upward trend in casual usage as the pandemic began.

#F. Distance by membership

ride_distance_chart <- all_trips_clean %>% 
group_by(member_casual) %>%
  filter(trip_duration < 10000) %>% 
  ggplot(aes(x = trip_duration, fill = member_casual)) + 
  geom_histogram()  +
  labs(
    title = "Average Monthly Distance",
    x = "trip_duration",
    y = "count",
  ) +
  theme_minimal()

print(ride_distance_chart)

#Key Findings:
#- Members take many short trips; casual riders take fewer but longer trips.
#- Long trips are rare for both groups.
#Conclusion: Members show commuting-style usage, while casual riders show more leisure-focused behavior.