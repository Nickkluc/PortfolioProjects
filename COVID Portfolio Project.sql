-- Select Data we are  going to use

SELECT location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total cases vs total deaths
-- Shows likehood of dying if you contract covid in your country
SELECT location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states'
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows  what percentage of population got covid

SELECT location, Date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states'
ORDER BY 1,2

-- Looking at Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with highest death count per population
--when it's nvarchar, SELECT location, MAX(total_deaths) AS TotalDeathCount

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- By Continent

--Showing continents with highest death count

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

--Total Deaths by date
SELECT date, SUM(new_cases) as TotalGlobalCases, SUM(new_deaths) as TotalGlobalDeaths
,SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage
FROM CovidDeaths
WHERE (continent is not null)
AND
(new_cases != 0)
AND
(new_deaths != 0)
GROUP BY date
ORDER BY 1,2

--Total deaths 
SELECT SUM(new_cases) as TotalGlobalCases, SUM(new_deaths) as TotalGlobalDeaths
,SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathPercentage
FROM CovidDeaths
WHERE (continent is not null)
--AND
--(new_cases != 0)
--AND
--(new_deaths != 0)
ORDER BY 1,2

SELECT location, date, new_cases, new_deaths
FROM CovidDeaths
WHERE (continent is not null)
AND
(new_cases != 0)
AND
(new_deaths != 0)
ORDER BY new_cases DESC


--Looking at Total Population vs Vaccinations

--Vaccinations Count by date
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- Partition By
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location =  vac.location
	AND dea.date = vac.date
WHERE (dea.continent is not null)
ORDER BY 2,3

--Using CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- Partition By
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location =  vac.location
	AND dea.date = vac.date
WHERE (dea.continent is not null)
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS GlobalVaccinatedPercentage
FROM PopvsVac

--Using Temp Tables
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_Vaccinations float,
RollingPeopleVaccinated float
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- Partition By
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location =  vac.location
	AND dea.date = vac.date
WHERE (dea.continent is not null)
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS GlobalVaccinatedPercentage
FROM #PercentPopulationVaccinated
--WHERE Location LIKE '%States%'

--Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
-- Partition By
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location =  vac.location
	AND dea.date = vac.date
WHERE (dea.continent is not null)
--ORDER BY 2,3

