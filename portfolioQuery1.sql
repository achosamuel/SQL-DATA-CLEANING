		--	DATA CLEANING OF COVID_DEATHS and COVID_VACCINATION WITH  85172 ROWS AND 27 COLUMNS

SELECT *
FROM PortfolioProject..CovidDeaths

-- continent column for continent and location for country but we have found continent in location 
-- with continent column null

SELECT*
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
ORDER BY 3,4

-- go send continent in location column to continent column 

UPDATE PortfolioProject..CovidDeaths
SET continent = COALESCE(continent,location )
WHERE continent IS NULL


-- go delete continent in location column

UPDATE PortfolioProject..CovidDeaths
SET location = NULL
WHERE location = continent


                     --------------------------------------------------------------------------------------


--looking at total cases vs total deaths (likeihood of dying if you contract covid in your country) 

SELECT location,MAX(total_cases) AS Total_Case,MAX(cast(total_deaths as int)) AS Total_death,
CAST(MAX(cast(total_deaths as int))/ MAX(total_cases)AS DECIMAL(10,2))*100 Likeihood
FROM PortfolioProject..CovidDeaths
WHERE location IS NOT NULL
GROUP BY location
ORDER BY  Likeihood DESC


--looking at the total cases vs population
--shows what percentage of population got covid

SELECT location,date,population,total_cases,total_deaths,(total_cases/population)*100 deathperpopulation
FROM PortfolioProject..CovidDeaths
ORDER BY  1,2 ASC

--TOP 5 countries with highest infection rate compared to population 

SELECT TOP 5
location,population,max(total_cases) highinfectioncount, 
CAST(max(total_cases/population)*100 AS DECIMAL(10,2)) case_percent
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY  case_percent desc

--TOP 5 country with highest death count per pop

SELECT TOP 5
location,population,max(cast(total_deaths as int)) deathcount
FROM PortfolioProject..CovidDeaths
where location IS NOT NULL
GROUP BY location,population
ORDER BY  deathcount DESC

-- TOP 5 continent with highest death count per pop

SELECT TOP 5
continent,max(cast(total_deaths as int)) deathcount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY  deathcount DESC


-- looking at total population vs vaccination 

SELECT dea.location,max(dea.population) population, sum(cast(new_vaccinations as int)) total_vaccinations
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..Covidvaccination VAC
	ON dea.location = vac.location and
		dea.date = vac.date
WHERE dea.continent is not null
and new_vaccinations is not null
GROUP BY dea.location
ORDER BY 1,2,3

--USE CTE 
with popvsvac (continent,location,date,population,vaccination,rollingpeoplevaccinated) as (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
	sum(convert(int,new_vaccinations)) over(
	partition by dea.location order by dea.location,dea.date ) rollingpeoplevaccinated
from PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..Covidvaccination VAC
	ON dea.location = vac.location and
		dea.date = vac.date
where dea.continent is not null
and new_vaccinations is not null
--group by dea.location
--order by 1,2,3 
)
select *, concat(cast((rollingpeoplevaccinated/population)*100 as decimal (10,4)) ,'%')
from popvsvac

-- temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
	sum(convert(int,new_vaccinations)) over(
	partition by dea.location order by dea.location,dea.date ) rollingpeoplevaccinated
from PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..Covidvaccination VAC
	ON dea.location = vac.location and
		dea.date = vac.date
where dea.continent is not null
and new_vaccinations is not null
--group by dea.location
--order by 1,2,3 


select *, concat(cast((rollingpeoplevaccinated/population)*100 as decimal (10,4)) ,'%')
from #percentpopulationvaccinated

--create view to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations ,
	sum(convert(int,new_vaccinations)) over(
	partition by dea.location order by dea.location,dea.date ) rollingpeoplevaccinated
from PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..Covidvaccination VAC
	ON dea.location = vac.location and
		dea.date = vac.date
where dea.continent is not null
and new_vaccinations is not null
--group by dea.location
--order by 2,3 

--(refresh : ctrl + shift+R)

select *
from percentpopulationvaccinated