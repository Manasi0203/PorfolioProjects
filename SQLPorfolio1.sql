/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select * 
From PortfolioProject..CovidDeaths
Order By 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2




  
--Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
  
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%ndia%'
Order By 1,2


  

--Total Cases vs Population
--Shows what percentage of population got Covid
  
Select location, date, population, total_cases,(total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Order By 1,2

  

--Countries with highest infection rate compared to population
  
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group By location, population
Order By PercentPopulationInfected DESC


  
--Countries with hightest death count per population
  
Select location, Max(total_deaths) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location
Order By TotalDeathCount DESC


Select location, Max(total_deaths) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group By location
Order By TotalDeathCount DESC

  

--Breaking down things by Continent
  
Select continent, Max(total_deaths) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount DESC



  
--Continents with highest death count per population
  
Select continent, Max(total_deaths) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount DESC


  
--Global Numbers
  
Select SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group By date
Order By 1,2


  

Select * 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date



  
--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


--USE CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (PeopleVaccinated/Population)*100
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3
  
Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


  

--Creating View to store data for later visualization

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

Select *
From PercentagePopulationVaccinated
