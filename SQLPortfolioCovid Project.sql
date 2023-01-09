--select * 
--from PortfolioProject.dbo.CovidDeath

--select * 
--from PortfolioProject..CovidDeaths$

--select location, date, total_cases, new_cases, Total_deaths, population
--from PortfolioProject..CovidDeath
--Where continent is not null
--order by 1,2


---- looking at total cases verses total deaths
---- Shows Likelyhood of dying if you contract covid in your country
--select location, date, total_cases, Total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
--from PortfolioProject..CovidDeath
--Where continent is not null'
--order by 1,2


---- Looking at Total cases verses Population
---- shows what percentage of population got covid
--select location, date, total_cases, Population,(total_cases/population)*100 as DeathPercentage
--from PortfolioProject..CovidDeath
--Where continent is not null
--order by 1,2


-- looking at countries with highest infection rate compared to population

select location, Population, MAX(Total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeath
Where continent is not null
group by Location, Population
order by PercentPopulationInfected desc


-- Showing countried with highest Death count per population

select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
Where continent is not null
group by Location
order by TotalDeathCount desc

-- Let's Break things down by continent. 
--Showing the continents with the highest death count

select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
Where continent is null 
group by Location
order by TotalDeathCount desc

-- Global Numbers

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeath
where continent is not null
group by date
order by 1,2

-- Lookign at total population vs toal vac

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeath dea
Join PortfolioProject.dbo.CovidDeaths$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
	order by 1,2,3



-- Use CTE


with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeath dea
Join PortfolioProject.dbo.CovidDeaths$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--	order by 1,2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- Temp Table

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeath dea
Join PortfolioProject.dbo.CovidDeaths$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for future visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeath dea
Join PortfolioProject.dbo.CovidDeaths$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3