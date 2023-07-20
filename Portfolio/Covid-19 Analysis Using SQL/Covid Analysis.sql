USE portfolio;

SELECT * FROM CovidDeaths ORDER BY location, date;

SELECT * FROM CovidVaccinations ORDER BY location, date;

--DELETE FROM CovidDeaths
--DROP TABLE CovidVaccinations;
--exec sp_rename CovidVaccinations$, CovidVaccinations

--Selecting data that we are going to use

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY location,date

-- Looking at total cases VS total deaths
--Shows likelihood of dying if you have covid in your country
SELECT location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 As DeathPercentage
FROM CovidDeaths
WHERE location like '%States%'
ORDER BY location,date


-- Looking at total cases vs Populations
--Shows what percentage of population get Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 As CovidPercentage
FROM CovidDeaths
WHERE location like '%States%'
ORDER BY location,date


-- Which country has highest infection rate
SELECT location, Max(total_cases) AS highestInfectionCount, population, Max((total_cases/population))*100 As PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing countries with highest death count per population
SELECT location, Max(total_deaths) AS Total_Death, Max((total_deaths/population))*100 As PercentPopulationDeath
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death DESC

--Let us check by Continent

SELECT location, Max(total_deaths) AS Total_Death, Max((total_deaths/population))*100 As PercentPopulationDeath
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY Total_Death DESC

SELECT location, Max(total_deaths) AS Total_Death, Max((total_deaths/population))*100 As PercentPopulationDeath
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death DESC

-- Showing continents with highest death count per population

SELECT continent, Max(total_deaths) AS Total_Death, Max((total_deaths/population))*100 As PercentPopulationDeath
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death DESC

-- Global data Total cases, deaths and deaths per cases

SELECT date,Sum(new_cases)As Total_cases, SUM(new_deaths) AS Total_Deaths, (Sum(new_deaths)/SUM(new_cases))*100 As DeathPercentages
FROM CovidDeaths
WHERE continent is not null
Group by date
ORDER BY date,Total_cases

--Exploring CovidVaccinations table

--Using CTE

WITH popVsvac (Continent,Location,Date,Population,New_vaccinations,Commulative_frequency)
AS
(
SELECT dae.continent, dae.location , dae.date , dae.population , vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dae.location ORDER BY dae.location, dae.date ) AS Commulitive_frequency
FROM CovidDeaths dae 
JOIN CovidVaccinations vac
	On dae.location = vac.location
	AND	dae.date = vac.date
WHERE dae.continent IS NOT NULL
--ORDER BY dae.location, dae.date 
)
SELECT *, (Commulative_frequency/population)*100 AS PercentPerPop
FROM popVsvac;


--Temp Table

DROP TABLE IF EXISTS #personPopulationVaccinated
CREATE TABLE #personPopulationVaccinated
(
 continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 new_vaccinations numeric,
 rollingPeopleVaccinated numeric
 )

INSERT INTO #personPopulationVaccinated
SELECT dae.continent, dae.location , dae.date , dae.population , vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dae.location ORDER BY dae.location, dae.date ) AS Commulitive_frequency
FROM CovidDeaths dae 
JOIN CovidVaccinations vac
	On dae.location = vac.location
	AND	dae.date = vac.date
--WHERE dae.continent IS NOT NULL
--ORDER BY dae.location, dae.date 

SELECT*, (rollingPeopleVaccinated /Population)*100
FROM #personPopulationVaccinated


-- Creating view to store data visualization

CREATE VIEW personPopulationVaccinated AS
SELECT dae.continent, dae.location , dae.date , dae.population , vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition BY dae.location ORDER BY dae.location, dae.date ) AS Commulitive_frequency
FROM CovidDeaths dae 
JOIN CovidVaccinations vac
	On dae.location = vac.location
	AND	dae.date = vac.date
WHERE dae.continent IS NOT NULL
--ORDER BY dae.location, dae.date 

f






