/*
COVID-19 Data Exploration 

Skills Used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Coverting Data Types
*/

SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths 
-- Shows the Likelihood of dying if you contract COVID in your country 

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS int) /CAST(total_cases AS int))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population 
-- Shows what percentage of population infected with COVID 

SELECT Location, date, Population, total_cases, (CAST(total_cases AS int)/population)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population 

SELECT Location, Population, MAX(CAST(total_cases AS int)) as HighestInfectionCount
	, MAX((CAST(total_cases AS int)/population))*100 as PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population 
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population 

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population 
ORDER BY TotalDeathCount DESC


-- Breaking down by CONTINENT --

-- Continent with the Highest Death Count per Population 

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL Numbers --

SELECT  SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths , SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations 
-- Showing Percentage of Population that has received at least one COVID Vaccine 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query 

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVac as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is not null