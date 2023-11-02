-- All the comments are written in English and Serbian / Svi komentari su napisani na srpskom i engleskom jeziku

-- Exploration of COVID 19 data from ourworldindata.com / Istrazivanje podataka o COVID 19


-- Selecting all the data / Odabir svih podataka
SELECT Location,date,total_cases, new_cases
, total_deaths, population FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Finding case-to-death percentage / Pronalazenje procenta umrlih od zabelezenih slucajeva
SELECT Location,date,total_cases, 
total_deaths,(total_deaths/total_cases)*100
AS DeathPercentage
FROM CovidDeaths 
WHERE location like '%serbia%'
AND continent is not null
ORDER BY 1,2

-- Finding case-to-population percentage / Pronalazenje procenta zarazenih od populacije
SELECT Location,date, 
population,total_cases,(total_cases/population)*100
AS PercentOfPopulation
FROM CovidDeaths 
WHERE location like '%serbia%' AND 
continent is not null
ORDER BY 1,2

-- Finding countries with highest infection rate compared to population / Pronalazenje drzava sa najvecim procentom zarazenih u populaciji
SELECT Location, 
population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100
AS PercentOfPopulation
FROM CovidDeaths 
WHERE continent is not null
GROUP BY location,population
ORDER BY PercentOfPopulation desc


-- Showing Countries with Highest Death Count per population / Prikazivanje drzava sa najvecim brojem umrlih u populaciji
SELECT Location,MAX(cast (Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths 
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Showing continents with the highest death count / Prikazivanje kontinenata sa najvecim brojem umrlih
SELECT continent,MAX(cast (Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths 
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Showing total data by each day / Prikazivanje ukupnih podataka za svaki dan
SELECT date, SUM(new_cases) as total_cases
, SUM(cast(new_deaths as int)) as total_deaths
-- total_deaths,(total_deaths/total_cases)*100
,SUM(cast(new_deaths as int))/SUM(new_cases)*100
AS DeathPercentage
FROM CovidDeaths 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Comparing population with number of vaccinated people / Uporedjivanje populacije sa brojem vakcinisanih
With PopvsVac (Continent,Location,Date,Population,
New_Vaccinations,RollingPeopleVaccinated) as(
SELECT dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.Location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Creating View to store data for later visualizations / Kreiranje Pogleda za cuvanje podataka radi kasnijih vizuelizacija
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,SUM(cast(vac.new_vaccinations as int))
OVER (Partition by dea.Location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null