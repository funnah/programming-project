########################
## PART 2
########################
# What are the best times and days of the week to minimise delays each year?

# ======== load libraries ========

library(DBI) # To manage large dataset
library(dplyr) # For data manipulation
library(ggplot2) # For data visualisation
library(readr) # For reading CSV files
library(tidyr)

# ======== create the database ========

conn <- dbConnect(RSQLite::SQLite(), "airline1_r.db")

# ======== write to the database ========

# Load in the data from the CSV files
airports <- read_csv("airports.csv")
carriers <- read_csv("carriers.csv")
planes <- read_csv("plane-data.csv")
dbWriteTable(conn, "airports", airports)
dbWriteTable(conn, "carriers", carriers)
dbWriteTable(conn, "planes", planes)

# Create a loop to load 1999-2008 ontime data files directly
for(i in c(1999:2008)) {
  filename <- paste0(i, ".csv")
  print(paste("Processing:", filename))
  ontime <- read.csv(filename, header = TRUE)
  if(i == 1999) {
    dbWriteTable(conn, "ontime", ontime)
  } else {
    dbWriteTable(conn, "ontime", ontime, append = TRUE)
  }
}

# View the list of tables and list of fields within each table
dbListTables(conn)
dbListFields(conn, "ontime")
dbListFields(conn, "airports")
dbListFields(conn, "carriers")
dbListFields(conn, "planes")

########################
## PART 2(A)
########################
# Load libraries
library(DBI)    # For database operations
library(dplyr)  # For data manipulation
library(ggplot2) # For data visualization
library(readr)  # For reading CSV files

# Establish database connection
conn <- dbConnect(RSQLite::SQLite(), "airline1_r.db")

# Load supplementary data from CSV files into the database
airports <- read_csv("airports.csv")
carriers <- read_csv("carriers.csv")
planes <- read_csv("plane-data.csv")

dbWriteTable(conn, "airports", airports)
dbWriteTable(conn, "carriers", carriers)
dbWriteTable(conn, "planes", planes)

# Load 1999-2008 ontime data files into the database
for (i in 1999:2008) {
  filename <- paste0(i, ".csv")
  print(paste("Processing:", filename))
  ontime <- read_csv(filename)
  
  if (i == 1999) {
    dbWriteTable(conn, "ontime", ontime)
  } else {
    dbWriteTable(conn, "ontime", ontime, append = TRUE)
  }
}

# Define the SQL query to calculate average delays by Year, DayOfWeek, and DepTime
sql_query <- "
SELECT Year,
       CRSDepTime,
       DayOfWeek,
       AVG(DepDelay + ArrDelay) AS avg_delay
FROM ontime
WHERE Year BETWEEN 1999 AND 2008
  AND CRSDepTime IS NOT NULL
  AND CRSArrTime IS NOT NULL
GROUP BY Year, CRSDepTime, DayOfWeek
"

# Execute the SQL query and store the result in a DataFrame
part2a <- dbGetQuery(conn, sql_query)

# Convert DayOfWeek to factor with proper levels
part2a$DayOfWeek <- factor(part2a$DayOfWeek, levels = 1:7,
                           labels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))

# Group the data by Year, DayOfWeek, and DepTime, and calculate the average delay
delay_summary <- part2a %>%
  group_by(Year, DayOfWeek, CRSDepTime) %>%
  summarize(avg_delay = mean(avg_delay, na.rm = TRUE))

# Find the best times and days of the week that minimize delays for each year
best_times_per_year <- delay_summary %>%
  group_by(Year) %>%
  filter(avg_delay == min(avg_delay)) %>%
  ungroup()

# Plotting
ggplot(best_times_per_year, aes(x = factor(DayOfWeek), y = CRSDepTime, fill = factor(Year))) +
  geom_tile() +
  scale_fill_viridis_d() +
  labs(x = "Day of Week",
       y = "Scheduled Departure Time",
       title = "Best Times and Days to Minimise Delays Each Year",
       fill = "Year") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

# Print the results
print("The best times and days of the week that minimise delays each year:")
print(best_times_per_year)

# Close the database connection
dbDisconnect(conn)

########################
## PART 2(B)
########################
# Evaluate whether older planes suffer more delays on a year-to-year basis.

# Establish SQLite database connection
conn <- dbConnect(RSQLite::SQLite(), "airline1_r.db")

# Query the database to get the necessary data for Part 2(b)
part2b <- dbGetQuery(conn,
                     "SELECT o.Year,
                             p.year AS plane_year,
                             AVG(o.ArrDelay + o.DepDelay) AS avg_delay
                      FROM ontime o
                      JOIN planes p ON o.TailNum = p.tailnum
                      WHERE o.Year BETWEEN 1999 AND 2008
                      GROUP BY o.Year, p.year")

# Filter out rows with non-numeric values in plane_year column
part2b <- part2b %>%
  filter(!is.na(plane_year) & plane_year != "None" & plane_year != "0000")

# Convert plane_year to numeric
part2b$plane_year <- as.numeric(part2b$plane_year)

# Calculate the age of the plane
part2b <- part2b %>%
  mutate(plane_age = Year - plane_year)

# Plot the relationship between plane age and average delay
ggplot(part2b, aes(x = plane_age, y = avg_delay)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Plane Age (years)", y = "Average Delay (minutes)") +
  theme_minimal()

# Find the year with the highest average delay
max_delay_year <- part2b %>%
  filter(avg_delay == max(avg_delay)) %>%
  pull(Year) %>%
  unique()

# Find the year with the lowest average delay
min_delay_year <- part2b %>%
  filter(avg_delay == min(avg_delay)) %>%
  pull(Year) %>%
  unique()

# Print the results
cat("The year with the highest average delay is:", max_delay_year, "\n")
cat("The year with the lowest average delay is:", min_delay_year, "\n")

# Close the database connection
dbDisconnect(conn)

########################
## PART 2(C)
########################
# For each year, fit a logistic regression model for the probability of diverted US flights using as many features as possible from attributes of the departure date, the scheduled departure and arrival times, the coordinates and distance between departure and planned arrival airports, and the carrier. Visualise the coefficients across years.

# Load required libraries
library(DBI)
library(dplyr)
library(ggplot2)
library(parallel)

# Establish database connection
conn <- dbConnect(RSQLite::SQLite(), "airline1_r.db")

# Define SQL query to retrieve relevant data
sql_query <- "
SELECT Year, Month, DayOfWeek, DepTime, CRSDepTime, ArrTime, CRSArrTime,
       UniqueCarrier, FlightNum, TailNum, Distance, Cancelled, Diverted
FROM ontime
WHERE Year BETWEEN 1999 AND 2008
"

# Execute SQL query and store result in a DataFrame
data <- dbGetQuery(conn, sql_query)

# Define function to fit logistic regression model for a given year
fit_model <- function(year, data) {
  year_data <- filter(data, Year == year)
  model <- tryCatch(
    glm(Diverted ~ ., data = year_data, family = "binomial"),
    error = function(e) {
      cat("Error fitting model for year", year, ":", conditionMessage(e), "\n")
      return(NULL)
    }
  )
  return(model)
}

# Fit logistic regression models in parallel using 2 cores
cl <- makeCluster(2)
clusterExport(cl, c("filter", "data"))
models <- parLapply(cl, unique(data$Year), fit_model, data = data)
stopCluster(cl)

# Extract coefficients from each model
coefficients <- lapply(models, coef)

# Combine coefficients into a single data frame
coefficients_df <- bind_rows(lapply(seq_along(coefficients), function(i) {
  year <- unique(data$Year)[i]
  if (is.null(coefficients[[i]])) {
    return(NULL)  # Skip if model fitting failed
  }
  coefficients_df <- data.frame(year = year, Variable = names(coefficients[[i]]), Estimate = coefficients[[i]])
  return(coefficients_df)
}))

# Filter out NULL values
coefficients_df <- coefficients_df[!sapply(coefficients_df, is.null)]

# Convert 'year' to factor
coefficients_df$year <- factor(coefficients_df$year)

# Plot coefficients across years
ggplot(coefficients_df, aes(x = year, y = Estimate, color = Variable)) +
  geom_point() +
  geom_line() +
  labs(title = "Coefficients of Logistic Regression Models for Diverted Flights",
       x = "Year",
       y = "Coefficient Estimate",
       color = "Variable") +
  theme_minimal()

# Disconnect from database
dbDisconnect(conn)