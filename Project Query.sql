SELECT *
FROM [PortfolioProject].[dbo].[CovidDeaths]
ORDER BY 3,4;

SELECT *
FROM [PortfolioProject].[dbo].[CovidVaccinations]
ORDER BY 3,4;


SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- The percentage of total mortality

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS MortalityRate
FROM PortfolioProject..CovidDeaths
WHERE total_deaths > 0 AND total_cases > 0 AND location LIKE '%bangladesh%'
ORDER BY 1,2

-- Total Case vs Population
-- The persentage of people that got affected

SELECT location, date, population,total_cases, 
(total_cases/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE total_cases > 0 AND location LIKE '%Bangladesh%'
ORDER BY 1,2

-- highest infection rate of a country

SELECT location, population, MAX(total_cases) AS FinalCases, 
MAX((total_cases/population))*100 AS FinalInectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY FinalInectionRate DESC

-- Countries with highest death rate

SELECT location, MAX(CAST(total_deaths AS INT)) AS FinalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY FinalDeathCount DESC

-- Result by continent with highest death count

SELECT location , MAX(CAST(total_deaths AS Int)) AS ContinentalDeath
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY ContinentalDeath DESC


SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeath
FROM [PortfolioProject]..[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeath DESC;

-- Global Numbers

SELECT 
	--date,
	SUM(new_cases) AS TotalCase, 
	SUM(CAST(new_deaths AS INT)) AS TotalDeath,
	CASE
		WHEN 
			SUM(new_cases) = 0 THEN NULL
		ELSE 
			(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 
	END AS DeathPersentage
FROM 
	[PortfolioProject].[dbo].[CovidDeaths]
--WHERE 
--	continent IS NOT NULL
--GROUP BY
--	date
ORDER BY 
	1,2 DESC;


-- Joining Deaths and Vaccinations



-- By CTE

WITH 
	PopvsVac(date, location, continent, population, new_vaccinations, RollingVaccinations) 
AS
(
SELECT 
	DEATH.location, DEATH.continent, DEATH.date, DEATH.population,VACC.new_vaccinations
	,SUM(CAST(VACC.new_vaccinations AS BIGINT)) OVER 
	(PARTITION BY DEATH.location 
	ORDER BY DEATH.location, DEATH.date) AS RollingVaccinations
	--,(RollingVaccination/DEATH.population)*100 AS PercentageVaccinated
FROM 
	[PortfolioProject].[dbo].[CovidDeaths] AS DEATH
JOIN 
	[PortfolioProject].[dbo].[CovidVaccinations] AS VACC
		ON 
			DEATH.date = VACC.date 
		AND 
			DEATH.location = VACC.location
WHERE 
	DEATH.continent IS NOT NULL AND VACC.new_vaccinations IS NOT NULL
--ORDER BY
--	1, 3 ASC
)


SELECT *, (RollingVaccinations/population)*100
FROM PopvsVac

-- By Temp Table

DROP TABLE IF EXISTS #PercentageOfVaccinated 
CREATE TABLE #PercentageOfVaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingVaccinations numeric
)


INSERT INTO #PercentageOfVaccinated
SELECT 
	DEATH.location, DEATH.continent, DEATH.date, DEATH.population,VACC.new_vaccinations
	,SUM(CAST(VACC.new_vaccinations AS BIGINT)) OVER 
	(PARTITION BY DEATH.location 
	ORDER BY DEATH.location, DEATH.date) AS RollingVaccinations
	--,(RollingVaccination/DEATH.population)*100 AS PercentageVaccinated
FROM 
	[PortfolioProject].[dbo].[CovidDeaths] AS DEATH
JOIN 
	[PortfolioProject].[dbo].[CovidVaccinations] AS VACC
		ON 
			DEATH.date = VACC.date 
		AND 
			DEATH.location = VACC.location
WHERE 
	DEATH.continent IS NOT NULL AND VACC.new_vaccinations IS NOT NULL


SELECT *
FROM #PercentageOfVaccinated


-- Data creation for views
DROP TABLE IF EXISTS VaccinatedPeople

CREATE VIEW VaccinatedPeople AS
SELECT 
	DEATH.location
	,DEATH.continent
	,DEATH.date
	,DEATH.population
	,VACC.new_vaccinations
	,SUM(CAST(VACC.new_vaccinations AS BIGINT)) OVER (PARTITION BY DEATH.location 
	ORDER BY DEATH.location, DEATH.date) AS RollingVaccinations

FROM 
	[PortfolioProject].[dbo].[CovidDeaths] AS DEATH
JOIN 
	[PortfolioProject].[dbo].[CovidVaccinations] AS VACC
		ON 
			DEATH.date = VACC.date 
		AND 
			DEATH.location = VACC.location
WHERE 
	DEATH.continent IS NOT NULL 
	AND VACC.new_vaccinations IS NOT NULL


-- View creation does not work directly
-- so, is created table then view from views

SELECT 
	DEATH.location
	,DEATH.continent
	,DEATH.date
	,DEATH.population
	,VACC.new_vaccinations
	,SUM(CAST(VACC.new_vaccinations AS BIGINT)) OVER (PARTITION BY DEATH.location 
	ORDER BY DEATH.location, DEATH.date) AS RollingVaccinations
INTO 
	VaccinatedPeople
FROM 
	[PortfolioProject].[dbo].[CovidDeaths] AS DEATH
JOIN 
	[PortfolioProject].[dbo].[CovidVaccinations] AS VACC
		ON 
			DEATH.date = VACC.date 
		AND 
			DEATH.location = VACC.location
WHERE 
	DEATH.continent IS NOT NULL 
	AND VACC.new_vaccinations IS NOT NULL


SELECT *
FROM VaccinatedPeople






