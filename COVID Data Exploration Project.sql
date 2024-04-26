
/*****COVID 19 DATA EXPLORATION 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types****/

--**** HERE WE ARE USING TWO CSV FILES  COVID DEATHS AND COVID VACCINATIONS****--

select * from protofolioProject..covid_deaths
where continent is not null
order by 3,4 -- order by location  and date 

ALTER TABLE protofolioProject..covid_deaths
ALTER COLUMN total_cases float;  -- Change the data type of total_cases column to float before it was string 

ALTER TABLE protofolioProject..covid_deaths
ALTER COLUMN total_deaths float; -- Change the data type of total_deaths column to Float begore it was string 

-------------looking at totaldeaths vs total cases in india-----------------

select Location, date, total_cases,new_cases,population, (total_deaths/total_cases)*100 as death_percentage from protofolioProject..covid_deaths
where location like '%india%'
order by 1,2 

--------looking at total cases vs population--------- 
--------shows what percentage of population got covid in india ----------

select Location, date, total_cases,new_cases,population, (total_cases/population)*100 as total_cases_per_population from protofolioProject..covid_deaths
where location like '%india%'
order by 1,2  -- order by Location and date 

-------looking for countires with highest infection rate compared to population------------

select Location,population, max(total_cases) as HighestInfectionCount , max((total_cases/population))*100 as percentage_populationInfection from protofolioProject..covid_deaths
--where location like '%india%'
group by Location,population
order by percentage_populationInfection desc 

-------showing countires with highest death count per population-----------

select Location,max(total_deaths) as total_deaths_count
from protofolioProject..covid_deaths
where continent is not null
group by Location
order by total_deaths_count desc

---------- lets break things down by contitent ---------

------- total_deaths_count per continent --------

select continent,max(total_deaths) as total_deaths_count
from protofolioProject..covid_deaths
where continent is not  null
group by continent
order by total_deaths_count desc

------ total_deaths to the total_cases and death_percentage ----------

select sum(new_cases) as total_cases , sum(new_deaths) as total_deaths , sum(new_deaths)/sum(new_cases)*100 as deathpercentage  from protofolioProject..covid_deaths
where continent is not null

-----------  how sum of total_cases and total_deaths  varing in date wise ---------------

select  date,sum(new_cases) as total_cases , sum(new_deaths) as total_deaths  
from protofolioProject..covid_deaths
where continent is not null
group by date 
order by 1 

---------- total number of vaccination by each contient -----------

select distinct(continent), sum(convert(bigint,new_vaccinations )) over(partition by continent) as total_vaccinations   from  protofolioProject..covidVaccinations
where continent is not null
--group by continent
order by continent

select distinct(location), sum(convert(bigint,new_vaccinations)) as each_location_vaccinations  from  protofolioProject..covidVaccinations 
where continent is not null group by location 

---------- finding each location  vaccinations and removing location  which is having  null vaccinated  -------------

select *from (select distinct(location),sum(convert(bigint,new_vaccinations)) as each_location_vaccinations  from  protofolioProject..covidVaccinations 
where continent is not null group by location )  as new_one
where each_location_vaccinations is not null
order by each_location_vaccinations desc


------ finding each location vaccinations orderby  date -------
select  continent, location, date,new_vaccinations from protofolioProject..covidVaccinations
where location='india' and  new_vaccinations is not null
order by date


--------- population vs vaccinated ----------------- 

with  popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations )) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from   protofolioProject..covid_deaths dea join protofolioProject..covidVaccinations 
vac on dea.location= vac.location and dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 as per_vaccinated  from popvsvac

--------- we can create another separate table  for percent Population Vaccinated ------------
-- creating temp table -- 

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
from protofolioProject..covid_deaths dea join  protofolioProject..covidVaccinations 
vac on dea.location= vac.location and dea.date=vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100 as per_vaccinated from percentPopulationVaccinated

----------- creating a temp table for number of death in Contient -----------

drop table if exists numberofdeathinContient
create table numberofdeathinContient
(
contient nvarchar(255),
total_deaths numeric
)
insert into numberofdeathinContient
select continent, sum(total_deaths) as total_deaths from protofolioProject..covid_deaths
where continent is not null
group by continent
order by continent  desc

select *from numberofdeathinContient

----- creating  view to store data for later visualization  ----
---- view is a temporary table that stores data when the environment is alive ----
--- Rolling people vaccinated ----

create view 
percent_Population_Vaccinated
as
select  dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations )) over(partition by dea.location order by dea.date) as RollingPeopleVaccinated
from protofolioProject..covid_deaths dea join  protofolioProject..covidVaccinations 
vac on dea.location= vac.location and dea.date=vac.date
where dea.continent is not null 

select *from percent_Population_Vaccinated -- to view the table 


