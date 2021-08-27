Select Top 1000 *
FROM PortfolioProjectTaylor..CovidDeaths

-- Looking at total cases vs total deaths

Select Location, date, total_cases, total_deaths, (Cast(total_deaths as float)/Cast(total_cases as float)) * 100 as DeathPercentage
FROM PortfolioProjectTaylor..CovidDeaths
WHERE location like '%states%'
Order By 1,2

-- Looking at total cases vs population

Select Location, date, total_cases, population, (Cast(total_cases as float)/Cast(population as float)) * 100 as InfectionPercentage
FROM PortfolioProjectTaylor..CovidDeaths
WHERE location like '%states%'
Order By 1,2

-- Looking at countries with highest infection rate compared to population

Select Location, MAX(total_cases) as HighestInfectionCount, population, (Cast(MAX(total_cases) as float)/Cast(population as float)) * 100 as InfectionRate
FROM PortfolioProjectTaylor..CovidDeaths
--WHERE location like '%states%'
WHERE population > 0
Group by population, location
Order By 4 DESC

-- Looking at countries with the highest death count per population

Select Location, MAX(total_deaths) as HighestDeathCount, population, (Cast(MAX(total_deaths) as float)/Cast(population as float)) * 100 as DeathRate
FROM PortfolioProjectTaylor..CovidDeaths
--WHERE location like '%states%'
WHERE population > 0
Group by population, location
Order By 4 DESC


-- Showing countries with the highest death counts
Select Location, CAST(MAX(total_deaths) AS INT) as TotalDeaths
FROM PortfolioProjectTaylor..CovidDeaths
--WHERE location like '%states%'
WHERE population > 0
AND continent != ''
Group by Location
Order by TotalDeaths DESC


-- Showing the Continents with the highest death counts
Select Location, CAST(MAX(total_deaths) AS INT) as TotalDeaths
FROM PortfolioProjectTaylor..CovidDeaths
--WHERE location like '%states%'
WHERE population > 0
AND continent = ''
Group by Location
Order by TotalDeaths DESC


-- Global numbers
Select SUM(CAST(new_cases as int)) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100 as DeathPercentage
FROM PortfolioProjectTaylor..CovidDeaths
WHERE new_cases > 0
AND continent = ''
--GROUP BY date
Order By 1,2


--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(Cast(vac.new_vaccinations As Int)) OVER (Partition By dea.Location Order By dea.Location, dea.Date) As RollingPeopleVaccinated
From PortfolioProjectTaylor..CovidDeaths dea
Join PortfolioProjectTaylor..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent != ''
Order by 2,3


-- Use CTE
With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
As (
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		,SUM(Cast(vac.new_vaccinations As Int)) OVER (Partition By dea.Location Order By dea.Location, dea.Date) As RollingPeopleVaccinated
	From PortfolioProjectTaylor..CovidDeaths dea
	Join PortfolioProjectTaylor..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent != ''
)

Select *, (RollingPeopleVaccinated/CAST(Population as float)) * 100 as VaccinationPercentage
From PopVsVac
Where Population > 0
Order By 2,3


--Temp Table
Drop Table if exists #PercentPeopleVaccinated

Create Table #PercentPeopleVaccinated (
	Continent nvarchar(255)
	,Location nvarchar(255)
	,Date Datetime
	,Population numeric
	,NewVaccinations numeric
	,RollingPeopleVaccinated numeric
)

Insert Into #PercentPeopleVaccinated
	Select dea.continent, dea.location, dea.date, CAST(dea.population as int), CAST(vac.new_vaccinations as int)
		,SUM(Cast(vac.new_vaccinations As Int)) OVER (Partition By dea.Location Order By dea.Location, dea.Date) As RollingPeopleVaccinated
	From PortfolioProjectTaylor..CovidDeaths dea
	Join PortfolioProjectTaylor..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent != ''

Select *, (RollingPeopleVaccinated/CAST(Population as float)) * 100 as VaccinationPercentage
From #PercentPeopleVaccinated
Where Population > 0
Order By 2,3


--Creating view to store data for later visualizations
--Create view vwPercentPopulationVaccinated as
--	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--		,SUM(Cast(vac.new_vaccinations As Int)) OVER (Partition By dea.Location Order By dea.Location, dea.Date) As RollingPeopleVaccinated
--	From PortfolioProjectTaylor..CovidDeaths dea
--	Join PortfolioProjectTaylor..CovidVaccinations vac
--		On dea.location = vac.location
--		and dea.date = vac.date
--	Where dea.continent != ''