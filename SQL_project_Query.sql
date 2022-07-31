select * from Portfolioproject..CovidDeaths
order by 3,4

select * from Portfolioproject..CovidVaccinations
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from Portfolioproject..CovidDeaths
order by 1,2

--Total cases vs Total deaths

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2

--Total cases vs population
select location,date,population,total_cases,(total_cases/population)*100 as Infectedpercentage
from Portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2

--Countries with highest infection rate compared to population
select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/total_cases))*100 as percentpopulationinfected
from Portfolioproject..CovidDeaths
group by location,population
order by percentpopulationinfected desc

--Countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Countries with highest death count per population w.r.t continent
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
select date,sum(new_cases) as totalcases,sum(cast (new_deaths as int)) as totaldeaths, (sum(cast (new_deaths as int))/sum(new_cases))*100 as deathpercentage
from Portfolioproject..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as totalcases,sum(cast (new_deaths as int)) as totaldeaths, (sum(cast (new_deaths as int))/sum(new_cases))*100 as deathpercentage
from Portfolioproject..CovidDeaths
where continent is not null
order by 1,2

--Total population vs Vaccinations
select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

with PopvsVac (continent,location,date,population, new_vacciantions,rolling_people_vaccinated)
as
(
select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as rolling_people_vaccinated
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)

select * , (rolling_people_vaccinated/population)*100   --TOP 10
from PopvsVac
 

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) as rolling_people_vaccinated
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select TOP 10 * , (rolling_people_vaccinated/population)*100   --TOP 10
from #percentpopulationvaccinated

--View for visualizations
create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date ,dea.population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated