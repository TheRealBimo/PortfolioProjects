select *
from covidportfolio..coviddeaths
where continent is not null
order by 3,4

--select *
--from covidportfolio..covidvaccinations
--order by 3,4

-- Select Data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidPortfolio..coviddeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from CovidPortfolio..coviddeaths
Where location like '%states%'
order by 1,2

-- Looking at the total cases vs population
-- shows what percentage of population got Covid
Select Location, date, population, total_cases, (total_cases/population)*100 PercentPopulationInfected
from CovidPortfolio..coviddeaths
Where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
Select Location, population, max(total_cases) HighestInfectionCount, max((total_cases/population))*100 PercentPopulationInfected
from CovidPortfolio..coviddeaths
--Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population
Select Location, max(cast(Total_deaths as int)) TotalDeathCount
from CovidPortfolio..coviddeaths
--Where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- This is showing the continents with the highest death count
Select continent, max(cast(Total_deaths as int)) TotalDeathCount
from CovidPortfolio..coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

Select date, sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
from CovidPortfolio..coviddeaths
where continent is not null
group by date
order by 1,2

-- Overview of total cases & deaths globally

Select sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 DeathPercentage
from CovidPortfolio..coviddeaths
where continent is not null
order by 1,2





-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
	dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolio..covidvaccinations vac
Join CovidPortfolio..coviddeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac 

-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
	Contintent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
	dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolio..covidvaccinations vac
Join CovidPortfolio..coviddeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated 



-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
	dea.date) RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidPortfolio..covidvaccinations vac
Join CovidPortfolio..coviddeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *
From PercentPopulationVaccinated