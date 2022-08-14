--SELECT * FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4


----SELECT * FROM PortfolioProject..CovidVaccinations
---- ORDER BY 3,4

----Select Data that we are going to be using

--Select Location, date, total_cases,new_cases, total_deaths, population 
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1,2

----Looking at Total Cases vs Total Deaths
----Shows likelihood of dying if you contract COVID in your country
--Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths
--where Location like '%state%'
--ORDER BY 1,2 

----Looking at Total Cases vs Population
----Shows what percentage of population get COVID

--Select Location, date, population, total_cases, (total_cases/population)*100 AS PopPercentage
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1,2 


----Looking at Countries with highest Infection Rate compared to Population


Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Looking at Top 10 Countries with highest Infection Rate

--Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
--PercentPopulationInfected, 
--FROM PortfolioProject..CovidDeaths
--GROUP BY location, population
--HAVING MAX((total_cases/population))*100 < 10
--ORDER BY 4 DESC

--Showing countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing continents with Highest Death Count per Population

Select continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global statistics

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
group by date
ORDER BY 1,2 



--Looking at Total Population vs. Vaccination, How many people in the world are vaccinated?

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3 


-- USING CTE to look at rolling percentage of people that are vaccinated

With PopulationvsVaccination (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3 
)

Select *, (RollingPeopleVaccinated/Population)*100 AS RollingPercentVaccinated
From PopulationvsVaccination


-- USING TEMP TABLE to look at rolling percentage of people that are vaccinated

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS RollingPercentVaccinated
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated