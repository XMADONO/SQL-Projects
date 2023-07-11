/*

Queries used for Tableau COVID Project 

*/


-- 1. Global Numbers 

SELECT SUM(new_cases) as total_cases, 
	   SUM(CAST(new_deaths as int)) as total_deaths,
	   SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2


-- 2. Total Deaths by Continent 

SELECT location,
	   SUM(CAST(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths 
WHERE continent is null 
	and location not in ('World', 'European Union', 'International', 'Low Income', 
						'Lower middle income', 'Upper middle income', 'High income')
GROUP BY location
ORDER BY TotalDeathCount DESC 


-- 3. Percent Population Infected by Country 

SELECT location,
	   population,
	   MAX(total_cases) as HighestInfectionCount,
	   (MAX(total_cases)/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location not in ('Low Income', 'Lower middle income', 'Upper middle income', 'High income')
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- 4. Percent Population Infected by Date

SELECT location,
	   population,
	   date,
	   MAX(total_cases) as HighestInfectionCount,
	   (MAX(total_cases)/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC 

