--------------------------------------COVID Data Exploration-----------------------------------------------------------



SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%' 
AND continent IS NOT NULL
ORDER BY 1,2 

-- Looking at the Total Cases vs Population
--Shows what percentage of population got COVID

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
ORDER BY 1,2 

--Look at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC 



-- Let's Break it in down by Continents
SELECT continent, MAX(CAST(total_deaths AS BIGINT)) AS TotalDeathCount, MAX(total_deaths/population) AS DeathCountperPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
GROUP BY continent
ORDER BY TotalDeathCount DESC 


--Show Countries with Highest Death Count Per Population

SELECT location, population, MAX(CAST(total_deaths AS BIGINT)) AS TotalDeathCount, MAX(total_deaths/population) AS DeathCountperPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY TotalDeathCount DESC 


--GLOBAL NUMBERS


SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS BIGINT)) AS TotalDeaths, SUM(CAST(new_deaths AS BIGINT))/SUM(New_cases)*100 
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2  



--Looking at Total Population vs Vaccinations

--I will do this by using 2 different methods (CTE & Temp Table)

-- USE CTE


WITH popvsVac (Continent, docation, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM popvsvac



-- Temp 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population nvarchar(255),
New_vaccinations FLOAT,
RollingPeopleVaccinated FLOAT
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--Create View to Store Data For Later Visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..Covid_Vaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
