      -------DATA CLEANING OF COVID_VACCINATION and COVID_DEATHS WITH  85172 ROWS AND 27 COLUMNS


--Display covid death tables

select*
from CovidDeaths

-- showing algeria total cases and total deaths

SELECT location , max(total_cases) total_cases,max(total_deaths) total_deaths
FROM CovidDeaths
where location like  '%algeria%'
group by location 

-- Display covid vaccinations tables 
select *
from Covidvaccination

--display covid death pertinent column

select continent, location , date, population, total_cases,new_cases,total_deaths,new_deaths
from CovidDeaths

-- population in each country

select location, MAX(population) total_population
from PortfolioProject..CovidDeaths
where continent is not null 
group by location 
order by location asc

-- looking at total people vaccinated in each country

select location, max(people_vaccinated) total_vaccinated
from PortfolioProject..Covidvaccination
where continent is not null
group by location 
order by location asc


--the percentage of the population vaccinated in each country NOTE: we don't have population column in cov_vaccinations tables 
--(using temp tables )

create table #total_population (
location nvarchar(255),
population numeric )

insert into #total_population
select location, MAX(population) total_population
from PortfolioProject..CovidDeaths
where continent is not null 
group by location 
order by location asc


create table #total_vaccinated (
location nvarchar(255),
people_vaccinated numeric )

insert into #total_vaccinated
select location, max(people_vaccinated) total_vaccinated
from PortfolioProject..Covidvaccination
where continent is not null
group by location 
order by location asc

--(calculate percentage of people vaccinated in each country with temp tables )

select pop.location ,population,people_vaccinated,
case
	when people_vaccinated is not null then concat(cast((people_vaccinated/population )*100 as decimal(10,4)),'%')
	when people_vaccinated is null then '0'
	else '0'
end vaccinatedPercentage
from #total_population pop
join #total_vaccinated vac
	on pop.location = vac.location 
order by location asc

--Examine the rate of vaccinations over year

select year(date) column_year , sum(cast(total_vaccinations as numeric)) total_vacc
from PortfolioProject..Covidvaccination
group by year(date)
order by total_vacc

--Examine the rate of vaccinations over month

select FORMAT(date,'MMM-yyy') new_date, sum(cast(total_vaccinations as numeric)) total_vacci
from PortfolioProject..Covidvaccination
--where total_vaccinations is not null
group by FORMAT(date,'MMM-yyy'),year(date), month(date)
order by year(date), month(date)

--Examine the rate of vaccinations over week

select concat(year(date),'-W', datepart(week,date)) column_WEEK,sum(cast(total_vaccinations as numeric)) total_vacci
from PortfolioProject..Covidvaccination
group by concat(year(date),'-W', datepart(week,date)),year(date)
order by year(date) asc, cast(substring (concat(year(date),'-W', datepart(week,date)) ,
	7,len(concat(year(date),'-W', datepart(week,date)) )) as numeric) asc

--countries with the highest vaccination rates relative to their population sizes.
select
	vac.location, max(population) total_pop, max(people_vaccinated) total_vaccinated,
	concat(CONVERT(decimal(10,2),(max(people_vaccinated)/max(population))*100),'%') as PercentVaccinated
from PortfolioProject..Covidvaccination vac
join PortfolioProject..CovidDeaths dea
	on vac.location = dea.location
	and dea.date = vac.date

--where people_vaccinated is not null AND dea.location like '%states%'

group by vac.location
order by max(people_vaccinated)/max(population)*100 desc

--likelihood of dying after contracting COVID-19 in each country

select location, max(total_cases) totalCases,max(total_deaths) totalDeaths, 
case
	when max(total_deaths) is not null then concat(
			convert(decimal(10,4),
			(max(total_deaths)/max(total_cases))*100 ),'%')
	else '0'
end Percentage_of_dying_after_case
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by Percentage_of_dying_after_case desc

--likelihood of dying after contracting COVID-19 in each continent

drop table if exists likelihood_case_dying
create table likelihood_case_dying 
( continent nvarchar(255), totalCases numeric, totalDeaths numeric, Percentage_of_dying_after_case varchar(255))

insert into likelihood_case_dying
select continent, max(total_cases) totalCases,max(total_deaths) totalDeaths, 
case
	when max(total_deaths) is not null then concat(
			convert(decimal(10,4),
			(max(total_deaths)/max(total_cases))*100 ),'%')
	else '0'
end Percentage_of_dying_after_case
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
-----

drop table if exists likelihood_case_dying2
create table likelihood_case_dying2
( continent nvarchar(255), totalCases numeric, totalDeaths numeric, Percentage_of_dying_after_case varchar(255))

insert into likelihood_case_dying
select location, max(total_cases) totalCases,max(total_deaths) totalDeaths, 
case
	when max(total_deaths) is not null then concat(
			convert(decimal(10,4),
			(max(total_deaths)/max(total_cases))*100 ),'%')
	else '0'
end Percentage_of_dying_after_case
from PortfolioProject..CovidDeaths
where continent is null
group by location

--------
select continent,sum(totalCases)totalCases,sum(totalDeaths) totalDeaths,
	sum(totalDeaths)/sum(totalCases) rate_of_dying_after_case
from likelihood_case_dying
group by continent
union
select continent,sum(totalCases) ,sum(totalDeaths),sum(totalDeaths)/sum(totalCases) 
from likelihood_case_dying2
group by continent
order by sum(totalDeaths)/sum(totalCases) desc

