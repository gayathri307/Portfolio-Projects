select * from protofolioProject..covid_deaths
where continent is not null
order by 3,4

--select * from protofolioProject..covidVaccinations
--order by 3,4
 select* from covid_deaths



--select Location, date, total_cases,new_cases,total_deaths,population from protofolioProject..covid_deaths
--order by 1,2

ALTER TABLE protofolioProject..covid_deaths
ALTER COLUMN total_cases float;  -- Change the data type of total_cases column to INT

ALTER TABLE protofolioProject..covid_deaths
ALTER COLUMN total_deaths float; -- Change the data type of total_deaths column to INT

--looking at totaldeaths vs total cases in india 

select Location, date, total_cases,new_cases,population, (total_deaths/total_cases)*100 as death_percentage from protofolioProject..covid_deaths
where location like '%india%'
order by 1,2 

--looking at total cases vs population 
--shows what percentage of population got covid

select Location, date, total_cases,new_cases,population, (total_cases/population)*100 as death_percentage from protofolioProject..covid_deaths
where location like '%india%'
order by 1,2 

--looking for countires with highest infection rate compared to population
select Location,population, max(total_cases) as HighestInfectionCount , max((total_cases/population))*100 as percentage_populationInfection from protofolioProject..covid_deaths
--where location like '%india%'
group by Location,population
order by percentage_populationInfection desc 



select Location,population, max(total_cases) as HighestInfectionCount , max((total_cases/population))*100 as percentage_populationInfection from protofolioProject..covid_deaths
where location like '%india%'
group by Location,population
--having location like '%india%'
order by percentage_populationInfection desc


--showing countires with highest death count per population 


select Location,max(total_deaths) as total_deaths_count
from protofolioProject..covid_deaths
where continent is not null
group by Location
order by total_deaths_count desc

--lets break things down by contitent 

select continent,max(total_deaths) as total_deaths_count
from protofolioProject..covid_deaths
where continent is not  null
group by continent
order by total_deaths_count desc


select sum(new_cases) as total_cases , sum(new_deaths) as total_deaths , sum(new_deaths)/sum(new_cases)*100 as deathpercentage  from covid_deaths
where continent is not null

-- GLOBAL NUMBERS 

select  date,sum(new_cases) as total_cases , sum(new_deaths) as total_deaths  
from covid_deaths
where continent is not null
group by date 
order by 1 




select distinct(location), sum(convert(bigint,new_vaccinations )) over(partition by location) from covidVaccinations
where location='Bahamas'

select  continent, location, date,new_vaccinations from covidVaccinations
where location='Bahamas' and  new_vaccinations is not null
order by date


--population vs vaccinated 

with  popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_deaths dea join covidVaccinations 
vac on dea.location= vac.location and dea.date=vac.date
where dea.continent is not null 
)
select (RollingPeopleVaccinated/population)*100 from popvsvac

--creating temp table 

drop Table if exists percentPopulationVaccinated
create table percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vainations numeric ,
RollingPeopleVaccinated  numeric 
)
insert into percentPopulationVaccinated
select  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_deaths dea join covidVaccinations 
vac on dea.location= vac.location and dea.date=vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100 from percentPopulationVaccinated

drop table if exists numberofdeathinContient
create table numberofdeathinContient
(
contient nvarchar(255),
total_deaths numeric
)
insert into numberofdeathinContient
select continent, sum(total_deaths) as total_deaths from covid_deaths
where continent is not null
group by continent
order by continent  desc

select *from numberofdeathinContient

--creating  view to store data for later visualization 
create view 
percent_Population_Vaccinated
as

select  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_deaths dea join covidVaccinations 
vac on dea.location= vac.location and dea.date=vac.date
where dea.continent is not null 

select *from percent_Population_Vaccinated



