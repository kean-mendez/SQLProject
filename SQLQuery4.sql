--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3,4

SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 2,3


-- Looking at total_cases vs total_deaths with percentage in Philippines
SELECT continent, location, date, total_cases, total_deaths, (CONVERT (DECIMAL, total_deaths)/ CONVERT (DECIMAL, total_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Philippines'
ORDER BY 2,3;


-- Looking at total_cases vs population
SELECT continent, location, date, total_cases, population, (CONVERT (DECIMAL, total_cases)/ CONVERT (DECIMAL, population))*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Philippines'
ORDER BY 2,3;


--Looking at the Max total_cases per population 
SELECT location, population, MAX(total_cases) AS MaxCases, MAX((total_cases/population))*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY  location, population
ORDER BY CasePercentage DESC


--Showing country with highest Death Count per Population.
SELECT location, population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeathCount DESC


-- Count Countries in a Continent
SELECT COUNT( DISTINCT location), continent
FROM PortfolioProject..CovidDeaths
GROUP BY continent


--Count Total death by continent
SELECT MAX(total_deaths) AS HighDeaths, location
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY HighDeaths DESC

--GLOBAL numbers
SELECT MAX(total_deaths) AS GlobalDeaths, location, SUM(CAST(total_deaths AS BIGINT))
FROM PortfolioProject..CovidDeaths
WHERE location NOT IN ('World','High income', 'Upper middle income', 'Lower middle income','Low income')
AND continent IS NULL
GROUP BY location


--Looking for population and vaccination
SELECT d.location, v.date, CAST(population AS BIGINT) AS TotalPopulation, CAST(new_vaccinations AS BIGINT) AS NewVaccinated
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccination AS V
		ON D.location = V.location
		AND D.date = V.date
WHERE D.continent IS NOT NULL
ORDER BY 1,2

--USING CTE with Rolling Summation
WITH CTE_SumofNewVaccinated AS(
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
       SUM(CONVERT(BIGINT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date ROWS UNBOUNDED PRECEDING) AS SumOfNewVaccinated
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccination AS V ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT population, SumofNewVaccinated, ( NULLIF(SumOfNewVaccinated, 0)/population)*100 AS VaccinationPercentage
FROM CTE_SumofNewVaccinated;


--Using temp Table
DROP TABLE IF exists #TemporaryTable
CREATE TABLE #TemporaryTable (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric
--SumofVaccinated numeric
)

INSERT INTO #TemporaryTable
SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations
       --SUM(CONVERT(BIGINT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date ROWS UNBOUNDED PRECEDING) AS SumOfNewVaccinated
FROM PortfolioProject..CovidDeaths AS D
JOIN PortfolioProject..CovidVaccination AS V ON D.location = V.location AND D.date = V.date
WHERE D.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM #TemporaryTable