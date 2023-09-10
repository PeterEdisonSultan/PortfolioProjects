Select *
From PortfolioProject1..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject1..CovidVaccinations
--order by 3,4

--Select data that we are h=going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths1
order by 1,2

--Looking at Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths1
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as
PercentPopulationInfected
From PortfolioProject1..CovidDeaths1
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--Looking at Countries with Highest Infection Rate compared to population

--LET'S BREAK IT DOWN BY CONTINENT

-- Showing countries death count per population


Select location,MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject1..CovidDeaths1
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/
SUM(new_cases)*100 as DeathPercentage  
From PortfolioProject1..CovidDeaths1
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
   dea.date) as RollingPeopleVaccinated 
,  
From PortfolioProject1..CovidDeaths1 dea
Join PortfolioProject1..CovidVaccination1 vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
   dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths1 dea
Join PortfolioProject1..CovidVaccination1 vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
)
-- order by 2,3
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
   dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths1 dea
Join PortfolioProject1..CovidVaccination1 vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create View PercentPopulationVaciinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
   dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths1 dea
Join PortfolioProject1..CovidVaccination1 vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
-- order by 2,3