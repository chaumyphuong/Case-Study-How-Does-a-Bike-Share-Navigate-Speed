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
