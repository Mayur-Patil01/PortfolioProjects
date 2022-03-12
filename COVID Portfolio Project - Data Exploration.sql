
/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


select * from PortfolioProject..coviddeaths
order by 3;

-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1,2


-- Looking for Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as deathpercentage
from PortfolioProject..coviddeaths
where location like '%India%'
order by 1,2


-- Looking at Total case vs Population
-- Shows what percentage of population got covid

select location, date, total_cases, population, round((total_deaths/population)*100,2) as infectedpercentage
from PortfolioProject..coviddeaths
where location like '%India%'
order by 1,2


-- Looking at countries with highest infection rate compared to population

select location, max(total_cases) as highestinfectioncount, population, round(max((total_deaths/population)*100),2) as infectedpercentage
from PortfolioProject..coviddeaths
-- where location like '%India%'
group by location, population
order by infectedpercentage desc


-- Showing countries with Highest death count per population

select location, max(total_deaths * 1) as totaldeathcount
from PortfolioProject..coviddeaths
-- where location like '%India%'
where continent is not null
group by location
order by totaldeathcount desc


-- Lets break things down by continent 
-- Showing continents with Highest death count per population

select continent, max(total_deaths * 1) as totaldeathcount
from PortfolioProject..coviddeaths
-- where location like '%India%'
where continent is not null
group by continent
order by totaldeathcount desc


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2


-- Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 




