

Select *
From PortfolioProject..CovidDeaths
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4

--Select Data that we are going to use


Select location, date, total_cases_per_million, new_cases, total_deaths, population_density 
From PortfolioProject..CovidDeaths
Order by 1,2


------------look at total cases vs total death
---Shows likelihood of dying if you contract the covid in your country

Select location, date, new_cases, total_deaths, (total_deaths/new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'portugal'
and continent is not null
Order by 1,2

-------

Select location, date, total_cases_per_million, new_cases, total_deaths, population_density 
From PortfolioProject..CovidDeaths
--Where location like 'Portugal'
Where continent is not null
Order by 1,2

--------


----Looking at Total Cases VS population
---Shows What Percentage of Population got Covid

Select location, date, total_cases_per_million, population_density, (total_cases_per_million/population_density)*100 as 
From PortfolioProject..CovidDeaths
--Where location like 'Portugal'
Where continent is not null
Order by 1,2


----Looking at Countries with Highest Infection Rate compared to Population


Select location, population_density, MAX(total_cases_per_million) as HighestInfectionCount, MAX(total_cases_per_million/population_density)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'Portugal'
Where continent is not null
Group by location, population_density
Order by PercentPopulationInfected desc


---Showing Countries with Highest Death Count per Population


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
--Where location like '%portugal%'
Where continent is not null
Group by location
Order by TotalDeathCounts desc


Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4


--LETS BREAKDOWN THINGS BY CONTINENT 


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
--Where location like '%portugal%'
Where continent is not null
Group by continent
Order by TotalDeathCounts desc

--

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
--Where location like '%portugal%'
Where continent is null
Group by location
Order by TotalDeathCounts desc


--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
--Where location like '%portugal%'
Where continent is not null
Group by continent
Order by TotalDeathCounts desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_deaths)/SUM(cast(new_deaths as int))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'portugal'
Where continent is not null
--Group by date
Order by 1,2


-- Looking at Total Population vs Vaccinations

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date


Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccionations,
SUM(cast(vac.new_vaccionations as int)) OVER (Partition by dea.location)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3
--OR (Exactly same thing)
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccionations,
SUM(CONVERT(int,vac.new_vaccionations)) OVER (Partition by dea.location)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

------------------------

Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccionations,
SUM(CONVERT(int,vac.new_vaccionations)) OVER (Partition by dea.location Order bydea,location, dea.date)
as RollingPeopleVaccinated, (RollingPeopleVaccinated/population_density)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-----USE CTE

With PopvsVac (continent, location, date, population_density, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccionations,
SUM(CONVERT(int,vac.new_vaccionations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population_density)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population_density)*100
From PopvsVac


----TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccionations,
SUM(CONVERT(int,vac.new_vaccionations)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated --, (RollingPeopleVaccinated/population_density)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

Select *, (RollingPeopleVaccinated/population_density)*100
From #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_deaths)/SUM(cast(new_deaths as int))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'portugal'
Where continent is not null
--Group by date
Order by 1,2


Select *
From PercentPopulationVaccinated
