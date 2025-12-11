

# COVID-19 Data Analysis (SQL Project)

  This project analyzes global COVID-19 data using **T-SQL**, performing deep exploration of cases, deaths, vaccinations, infection rates, mortality rates, and global trends.  
  The dataset includes two main tables:

- **CovidDeaths**
- **CovidVaccinations**

  The queries in this project demonstrate data cleaning, transformation, aggregation, joins, CTE usage, temp tables, window functions, and view creation.

---

## Project Contents

### ✔ Queries Included
- Exploring raw COVID data  
- Total cases vs. total deaths  
- Infection rate per population  
- Highest infection rates by country  
- Highest death counts (country & continent)  
- Global case and death numbers  
- Joining vaccination + death data  
- Rolling vaccination counts using window functions  
- CTE-based analysis  
- Temporary table analysis  
- Creating a final table/view (`VaccinatedPeople`)

---

## Key Insights

### **1️ Mortality Rate**
Calculates the percentage of deaths relative to total cases.

```sql
SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 AS MortalityRate
FROM PortfolioProject..CovidDeaths
WHERE total_deaths > 0 AND total_cases > 0 AND location LIKE '%bangladesh%'
ORDER BY 1,2;
````

---

### **2️ Infection Rate**

Shows how much of a population was infected.

```sql
SELECT location, date, population, total_cases,
(total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE total_cases > 0 AND location LIKE '%Bangladesh%'
ORDER BY 1,2;
```

---

### **3️ Countries With Highest Infection Rate**

```sql
SELECT location, population, MAX(total_cases) AS FinalCases,
MAX((total_cases/population))*100 AS FinalInectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY FinalInectionRate DESC;
```

---

### **4️ Highest Death Count (Countries & Continents)**

```sql
SELECT location, MAX(CAST(total_deaths AS INT)) AS FinalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY FinalDeathCount DESC;
```

---

### **5️ Global Statistics**

```sql
SELECT 
	SUM(new_cases) AS TotalCase,
	SUM(CAST(new_deaths AS INT)) AS TotalDeath,
	(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPersentage
FROM PortfolioProject..CovidDeaths;
```

---

## Vaccination Analysis

### **CTE Approach**

Rolling vaccination totals:

```sql
WITH PopvsVac AS (
SELECT 
	DEATH.location, DEATH.continent, DEATH.date, DEATH.population, VACC.new_vaccinations,
	SUM(CAST(VACC.new_vaccinations AS BIGINT)) OVER (
		PARTITION BY DEATH.location 
		ORDER BY DEATH.location, DEATH.date
	) AS RollingVaccinations
FROM PortfolioProject..CovidDeaths AS DEATH
JOIN PortfolioProject..CovidVaccinations AS VACC
	ON DEATH.date = VACC.date AND DEATH.location = VACC.location
WHERE DEATH.continent IS NOT NULL AND VACC.new_vaccinations IS NOT NULL
)
SELECT *, (RollingVaccinations/population)*100 AS PercentageVaccinated
FROM PopvsVac;
```

---

### **Temp Table Method**

```sql
CREATE TABLE #PercentageOfVaccinated (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccination numeric,
	RollingVaccinations numeric
);
```

---

### **Final Table / View Creation**

```sql
SELECT 
	DEATH.location, DEATH.continent, DEATH.date, DEATH.population,
	VACC.new_vaccinations,
	SUM(CAST(VACC.new_vaccinations AS BIGINT)) OVER (
		PARTITION BY DEATH.location ORDER BY DEATH.location, DEATH.date
	) AS RollingVaccinations
INTO VaccinatedPeople
FROM PortfolioProject..CovidDeaths AS DEATH
JOIN PortfolioProject..CovidVaccinations AS VACC
	ON DEATH.date = VACC.date AND DEATH.location = VACC.location
WHERE DEATH.continent IS NOT NULL AND VACC.new_vaccinations IS NOT NULL;
```

---

## Skills Demonstrated

* SQL Joins
* Aggregate Functions
* Window Functions (OVER, PARTITION BY)
* Common Table Expressions (CTEs)
* Temporary Tables
* View Creation
* Data Cleaning & Filtering
* Analytical Query Writing

---

## Purpose

This project showcases real-world analytical SQL skills using a globally relevant dataset.
It can be used for:

* Portfolio demonstration
* Data analysis learning
* Interview preparation
* BI/analytics skill practice

---

## License

Free to use and modify.

---

