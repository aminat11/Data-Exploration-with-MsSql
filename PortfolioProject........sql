---Selecting the entire data to verify the accuracy of the data loaded


Select *
From PortfolioProjects..Covid_Vaccination$
where continent is not null
Order by 3,4

Select *
From PortfolioProjects..Covid_Deaths$
where continent is not null
Order By 3, 4


--Selecting the Data needed for exploration
Select location, date, total_deaths, new_cases, population, total_cases
From PortfolioProjects..Covid_Deaths$
Order by 1,2

Select location, date, total_cases, total_deaths, population, (total_deaths/cast(total_cases as int))*100 as DeathPercentage
From PortfolioProjects..Covid_Deaths$
Order by DeathPercentage desc

Select location, date, total_cases, total_deaths, population
From PortfolioProjects..Covid_Deaths$
Where location like '%states%'
Order by 1, 2

Select location, date, total_cases, total_deaths, population
From PortfolioProjects..Covid_Deaths$
Where location like '%Nigeria%'
Order by 1, 2

Select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProjects..Covid_Deaths$
Order by 1,2

--Exploring the Countries with the highest infections by population
Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProjects..Covid_Deaths$
Group by location, population
Order by 4 desc

--Showing countries with the highest deathcount
Select Location, Max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProjects..Covid_Deaths$
where continent is not null
Group by location
Order by HighestDeathCount Desc

--Showing continents with the highest deathcount Using Location
Select location, Max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProjects..Covid_Deaths$
where continent is null
Group by location
Order by HighestDeathCount Desc

--Showing continents with the highest deathcount
Select continent, Max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProjects..Covid_Deaths$
where continent is not null
Group by continent
Order by HighestDeathCount Desc

--Global Numbers: Obtaining Values Across the world. i.e Total cases in the world
Select location, Max(cast(total_cases as int)) as TotalCasesCount
from PortfolioProjects..Covid_Deaths$
where location like '%world%'
Group by location
Order by TotalCasesCount Desc

--Joining the two tables

Select *
From PortfolioProjects..Covid_Deaths$ dea
	Join PortfolioProjects..Covid_Vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProjects..Covid_Deaths$ dea
	Join PortfolioProjects..Covid_Vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order By 2, 3

--Looking at Total population vs Population

With PopVsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..Covid_Deaths$ dea
	Join PortfolioProjects..Covid_Vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where vac.new_vaccinations is not null
where dea.continent is not null
--Order By 2, 3
)

Select *, (RollingPeopleVaccinated/population)*100 as PercentageRolling
From PopVsVac


--Temp Table

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..Covid_Deaths$ dea
	Join PortfolioProjects..Covid_Vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where vac.new_vaccinations is not null
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PercentageRolling
From #PercentagePopulationVaccinated


--Creating View for Visualisation
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects..Covid_Deaths$ dea
	Join PortfolioProjects..Covid_Vaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where vac.new_vaccinations is not null
where dea.continent is not null

select * 
from PercentagePopulationVaccinated