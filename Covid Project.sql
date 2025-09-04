SELECT *
FROM covid.covidvaccinations;

SELECT *
FROM covid.coviddeaths1;

SELECT location, 
STR_TO_DATE(`date`, '%d/%m/%Y') AS formatted_date,
 total_cases, new_cases, 
 total_deaths, population
FROM covid.coviddeaths1
ORDER BY 1,2;

-- Total Cases vs Total Deaths
-- Likelihood of dying if you contract covid in your region
SELECT location, 
STR_TO_DATE(`date`, '%d/%m/%Y') AS formatted_date, 
total_cases, total_deaths, 
(total_deaths/total_cases)*100 deathpercentage
FROM covid.coviddeaths1
WHERE location LIKE '%Africa%'
ORDER BY 1,2;

-- Total_cases vs Population
-- What percentage of population got covid
SELECT location, 
STR_TO_DATE(`date`, '%d/%m/%Y') AS formatted_date, 
total_cases, population, 
(total_cases/population)*100 percentpopulationinfected
FROM covid.coviddeaths1
WHERE location LIKE '%Africa%'
ORDER BY 1,2;

-- Countries with Highest Infection rate compared to population
SELECT location, 
population, 
MAX(total_cases) HighestInfectionCount, 
MAX(total_cases/population)*100 percentpopulationinfected
FROM covid.coviddeaths1
-- WHERE location LIKE '%Africa%'
GROUP BY location, population
ORDER BY percentpopulationinfected DESC;

-- Countries With Highest Death Count Per Population
SELECT location, 
MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM covid.coviddeaths1
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Continents with Highest Death Counts
SELECT continent,
MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathCount
FROM covid.coviddeaths1
WHERE continent != ''
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Deaths
SELECT 
STR_TO_DATE(`date`, '%d/%m/%Y') AS formatted_date,
SUM(new_cases) AS total_cases,
SUM(new_deaths) AS Total_Deaths,
 SUM(new_deaths)/SUM(new_cases)*100 AS  DeathPercentage
FROM covid.coviddeaths1
WHERE continent IS NOT NULL
GROUP BY `date`
ORDER BY 1,2 ;

SELECT 
SUM(new_cases) AS total_cases,
SUM(new_deaths) AS Total_Deaths,
 SUM(new_deaths)/SUM(new_cases)*100 AS  DeathPercentage
FROM covid.coviddeaths1
WHERE continent IS NOT NULL
ORDER BY 1,2 ;

SELECT *
FROM covid.covidvaccinations;

# Considering Total Population Vs vaccinations
SELECT dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RoliingVaccinations
FROM covid.coviddeaths1 AS dea
JOIN covid.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
;

# Using CTE
WITH PopVac_CTE (continent, location, date, population, new_vaccinations, RollingVaccinations) # NOte to self: SPecified columns here must be the same as that in the CTE
AS
(SELECT dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingVaccinations
FROM covid.coviddeaths1 AS dea
JOIN covid.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * , (RollingVaccinations/population)*100 RollingPercentage
FROM PopVac_CTE
;


# Creating View to Store Data For Visualization
CREATE VIEW PopVac_CTE AS 
SELECT dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingVaccinations
FROM covid.coviddeaths1 AS dea
JOIN covid.covidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


CREATE VIEW GlobalDeaths AS
SELECT 
STR_TO_DATE(`date`, '%d/%m/%Y') AS formatted_date,
SUM(new_cases) AS total_cases,
SUM(new_deaths) AS Total_Deaths,
 SUM(new_deaths)/SUM(new_cases)*100 AS  DeathPercentage
FROM covid.coviddeaths1
WHERE continent IS NOT NULL
GROUP BY `date`
ORDER BY 1,2 ;