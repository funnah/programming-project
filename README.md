# ✈️ Programming for Data Science: MCMC Simulation & Flight Delay Analysis

This project combines a simulation-based algorithm (Markov Chain Monte Carlo) with real-world airline flight data analysis, using Python, R, and SQL. It demonstrates both statistical programming and applied data science, covering simulation diagnostics, delay analysis, logistic regression, and large-scale database handling.

---

## 🧪 Part 1: Markov Chain Monte Carlo (MCMC) — Metropolis-Hastings

Simulates random numbers from a non-standard distribution using the **Random Walk Metropolis algorithm**, and evaluates convergence using **R-hat diagnostics**.

### 🔹 Tasks Performed:
- Implemented Metropolis-Hastings with `f(x) = ½ exp(−|x|)`
- Estimated probability distribution using histogram and KDE overlay
- Calculated Monte Carlo estimates for mean and standard deviation
- Evaluated convergence with R-hat values across different step sizes `s`

### 🛠 Tools:
- Python (NumPy, Matplotlib)
- R (base, ggplot2)

---

## ✈️ Part 2: Flight Delay Analysis (1999–2008, USA)

Analyzed U.S. flight records (~120M records total) using a SQLite database with queries from Python and R.

---

### 📅 2(a): Best Times & Days to Minimize Flight Delays

**Objective**: Identify optimal departure times and days of the week to avoid delays each year.

- Processed over 10 years of flight data from the ASA Data Expo 2009
- Grouped delays by weekday and time to determine ideal windows
- Visualized trends using ggplot2 and pandas

📊 **Result**: Identified yearly low-delay windows, aiding operational scheduling.

---

### ✈️ 2(b): Do Older Planes Cause More Delays?

**Hypothesis**: Older aircraft have higher average delays.

- Merged aircraft manufacture year with flight delay data
- Computed plane age and grouped by year for analysis
- Visualized plane age vs. delay trends in R and Python

📊 **Result**: Showed correlation between aircraft age and delay trends across years.

---

### 🔍 2(c): Logistic Regression on Diverted Flights

**Goal**: Predict the likelihood of a flight being diverted using logistic regression.

- Fitted models for each year using departure time, carrier, distance, and calendar attributes
- Categorical variables were dummy-encoded
- Compared coefficients across 10 years

📊 **Result**: Identified top diversion predictors (e.g. day of week, distance) and visualised trends across years.

---

## 🛠 Technologies & Tools Used

- **Languages**: Python, R, SQL
- **Libraries**:
  - Python: `pandas`, `sqlite3`, `matplotlib`, `seaborn`, `scikit-learn`
  - R: `ggplot2`, `dplyr`, `DBI`
- **Databases**: SQLite (12GB+ FAA flight dataset)
- **Notebooks**: Jupyter (Python) & RMarkdown (R)

---

## 📂 Dataset Source

📦 Harvard Dataverse:  
✈️ [https://doi.org/10.7910/DVN/HG7NV7](https://doi.org/10.7910/DVN/HG7NV7)  
ASA Data Expo 2009 — U.S. Domestic Flights (1987–2008)
