-- Original Query: Selects 
SELECT *
FROM CovidDeaths
WHERE continent is not null --Need this line because OG dataset has continent names like 'Asia'
ORDER BY 3,4 DESC

--SELECT location, total_vaccinations
--FROM CovidVaccinations
--WHERE total_vaccinations IS NOT NULL

---Select our desired data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by location, date

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the US (or your country)
SELECT 
     location, 
	 date, 
	 total_cases, 
	 total_deaths, 
	 (total_deaths/total_cases)*100 DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%States%'
order by location, date

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 
SELECT 
     location, 
	 date, 
	 total_cases, 
	 population,
	 (total_cases/population)*100 InfectedPercentage
FROM CovidDeaths
--WHERE location LIKE '%States%'
order by location, date

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT 
     location,  
	 population,
	 MAX(total_cases) Highest_Infection,
	 MAX(total_cases) / population * 100 InfectedPercentageOfPopulation
FROM CovidDeaths
WHERE population > 1000000
GROUP BY location, population
order by 4 desc

--Looking at things by continent
SELECT continent, MAX(cast(total_deaths as int)) Highest_Deaths, MAX(population) Population
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent



-- Looking at Countries with the Highest Death Count per Population
SELECT 
     location,  
	 population,
	 MAX(cast(total_deaths as int)) Highest_Deaths,
	 MAX(cast(total_deaths as int)) / population * 100 DeathPercentageOfPopulation
FROM CovidDeaths
WHERE population > 1000000 AND continent is not null
GROUP BY location, population
order by 3 desc

-- Continent Selection revised
SELECT location, MAX(cast(total_deaths as int)) Highest_Deaths, MAX(population) Population
FROM CovidDeaths
WHERE continent is null AND population is not null
GROUP BY location

--Global numbers per date
SELECT 
    date, 
    SUM(new_cases) total_cases, 
    SUM(cast(new_deaths as int)) total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 NewDeathsPerNewCases
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

-- Total cases, Total Deaths for ALL countries combined
SELECT  
    SUM(new_cases) total_cases, 
    SUM(cast(new_deaths as int)) total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 NewDeathsPerNewCases
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
order by 1,2



--Adds up the highest total value from each country to find the amount of people who were vaccinated
SELECT sum(MAXES) Amount_of_people_vaccinated
FROM (SELECT dea.location, MAX(cast(vac.total_vaccinations as int)) MAXES
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.location
) as joins

--Joined two tables, one for covid deaths with covid vaccinations
--Using a window function to aggregate

--Used a CTE to aid in calculating the amount of people vaccinated and to streamline our process

WITH VacVsPop (Continent, Date, Location, Population, New_Vaccinations, RollingPplVaccinated) AS
(
SELECT dea.continent, dea.date, dea.location, dea.population, 
vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPplVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

)

SELECT *, (RollingPplVaccinated/Population) * 100 PctOfPeopleVaccinated FROM VacVsPop

--Created of an earlier query that information on the total deaths so far.
CREATE VIEW Total_Deaths AS
SELECT  
    SUM(new_cases) total_cases, 
    SUM(cast(new_deaths as int)) total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 NewDeathsPerNewCases
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date

Select * FROM Total_Deaths

CREATE VIEW PopDeathPercentage AS
SELECT 
     location,  
	 population,
	 MAX(cast(total_deaths as int)) Highest_Deaths,
	 MAX(cast(total_deaths as int)) / population * 100 DeathPercentageOfPopulation
FROM CovidDeaths
WHERE population > 1000000 AND continent is not null
GROUP BY location, population
--order by 3 desc

SELECT *
FROM PopDeathPercentage
Order By 3 desc