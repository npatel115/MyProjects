
Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4


--Select * 
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%United Kingdom%'
and continent is not null
order by 1,2 

--Looking at total cases vs total deaths^

--Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Where location like '%United Kingdom%'
and continent is not null
order by 1,2 


--Looking at countries with Highest infection rate compared to Population
Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%United Kingdom%'
Group By Location,Population
order by PercentPopulationInfected desc


-- Showing the countries with the Highest Death Count per Population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%United Kingdom%'
Where continent is not null
Group By Location
order by TotalDeathCount desc


--Breaking things down by continent
--Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%United Kingdom%'
Where continent is not null
Group By continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%United Kingdom%'
where continent is not null
--Group By date
order by 1,2 

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.Location, dea.Date) as RollingVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
--, (RollingPeopleVaccinated/population)*100
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopsVsVac (continent, location, date, population, new_vacinations, RollingVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.Location, dea.Date) as RollingVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
--, (RollingPeopleVaccinated/population)*100
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *,(RollingVaccinated/population)*100
From PopsVsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaccinated numeric,
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.Location, dea.Date) as RollingVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
--, (RollingPeopleVaccinated/population)*100
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *, (RollingVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating a view

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinated
--, (RollingVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 