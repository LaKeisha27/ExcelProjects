SELECT *
FROM projects..CovidDeaths
ORDER BY 3,4

--SELECT * 
--FROM projects..CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM projects..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your Country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM projects..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows wat percentage of population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentInfected
FROM projects..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentInfected
FROM projects..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentInfected DESC

--Showing Countries with Highest Death Count per population

SELECT Location,  MAX(cast(total_deaths AS int)) AS TotalDeathCount 
FROM projects..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breaking things down by Continent

--Showing continents with highest death count 

SELECT continent,  MAX(cast(total_deaths AS int)) AS TotalDeathCount 
FROM projects..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT  date, sum(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Deaths, SUM(cast(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM projects..CovidDeaths
WHERE continent is not NULL 
GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Total_Vaxxed
FROM projects..CovidDeaths dea
JOIN  projects..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopvsVax (Continent, Location, Date, Population,New_vaccionations, Total_Vaxxed)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Total_Vaxxed
FROM projects..CovidDeaths dea
JOIN  projects..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Total_Vaxxed/Population) * 100 AS Total_Population_Vaxxed
FROM PopvsVax
ORDER BY 2,3

--TEMP TABLE

DROP TABLE IF exists #TotalPopulationVaccinated
CREATE TABLE #TotalPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
Total_Vaxxed numeric
)

INSERT INTO #TotalPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Total_Vaxxed
FROM projects..CovidDeaths dea
JOIN  projects..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (Total_Vaxxed/Population) * 100 AS Total_Population_Vaxxed
FROM #TotalPopulationVaccinated
ORDER BY 2,3


--View for later visualizations

CREATE VIEW TotalPopulationVaxxed AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Total_Vaxxed
FROM projects..CovidDeaths dea
JOIN  projects..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL


CREATE VIEW Global_Numbers AS
SELECT  date, sum(new_cases) AS Total_Cases, SUM(cast(new_deaths AS int)) AS Total_Deaths, SUM(cast(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM projects..CovidDeaths
WHERE continent is not NULL 
GROUP BY date

CREATE VIEW Continent_Death_Count AS
SELECT continent,  MAX(cast(total_deaths AS int)) AS TotalDeathCount 
FROM projects..CovidDeaths
WHERE continent is not NULL
GROUP BY continent

CREATE VIEW Country_Death_Count AS
SELECT Location,  MAX(cast(total_deaths AS int)) AS TotalDeathCount 
FROM projects..CovidDeaths
WHERE continent is not NULL
GROUP BY location

CREATE VIEW Infection_Rate AS
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentInfected
FROM projects..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population