Select *
from CovidProject..CovidDeaths
where continent is NOT NULL
order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
where continent is NOT NULL
order by 1, 2

-- Looking at Total cases v/s Total Deaths
-- shows likelihood of dying if you contract Covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where location like '%canada%'
where continent is NOT NULL
order by 1, 2


-- Looking at the total cases v/s populations
-- shows what % of population got Covid
Select Location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
--where location like '%india%'
where continent is NOT NULL
order by 1, 2


-- Looking at countries with highest infection rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 
as PercentPopulationInfected
From CovidProject..CovidDeaths
-- where location like '%india%'
where continent is NOT NULL
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with highest deaths counts per population 
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCounts
From CovidProject..CovidDeaths
-- where location like '%india%'
where continent is NOT NULL
Group by Location
order by TotalDeathCounts desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCounts
From CovidProject..CovidDeaths
-- where location like '%india%'
where continent is NULL
Group by location
order by TotalDeathCounts desc

-- Breaking with continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCounts
From CovidProject..CovidDeaths
-- where location like '%india%'
where continent is NOT NULL
Group by continent
order by TotalDeathCounts desc


-- Global Numbers

Select -- date 
SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
-- where location like '%canada%'
where continent is NOT NULL
-- Group by date
order by 1, 2


-- Looking at Total Population v/s vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVacinated -- (RollingPeopleVacinated/population) *100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccine vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL -- and dea.location like '%India%'
order by 2, 3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVacinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVacinated -- (RollingPeopleVacinated/population) *100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccine vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL -- and dea.location like '%India%'
-- order by 2, 3
)
Select *, (RollingPeopleVacinated/Population)*100 From PopvsVac

-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric, 
RollingPeopleVacinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVacinated -- (RollingPeopleVacinated/population) *100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccine vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is NOT NULL -- and dea.location like '%India%'
-- order by 2, 3
Select *, (RollingPeopleVacinated/Population)*100 From #PercentPopulationVaccinated



-- Create view to save data for later
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location, dea.Date) as RollingPeopleVacinated -- (RollingPeopleVacinated/population) *100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccine vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is NOT NULL -- and dea.location like '%India%'
-- order by 2, 3

Select * From PercentPopulationVaccinated






