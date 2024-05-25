
select *
FROM PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2

--looking at Total cases vs Total Deaths
--shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
where location like '%Nigeria%'
and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select location, date, Population, total_cases,  (total_cases/Population)* 100 as percentpopulationinfected
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%Nigeria%'
order by 1,2


--looking at countries with highest infection rate compared to population
select Location, Population, max(total_cases) as HighestInfectionCount ,  max((total_cases/Population))* 100 as percentpopulationinfected
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by Location, Population
order by percentpopulationinfected desc

--showing the countries with yhe highest death count per population
select Location,max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--Breaking things down by continent

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--showing the continent with the highest death count per population

select continent, max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--where location like '%Nigeria%'
where continent is not null
--Group by date
order by 1,2

--Looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, New_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rollingpeoplevaccinated /population)*100
from PopvsVac
 

 --Temp table
 Drop Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 Rollingpeoplevaccinated numeric
 )
 Insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (Rollingpeoplevaccinated /population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations

create view dbo.PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated/population)*100
FROM PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated