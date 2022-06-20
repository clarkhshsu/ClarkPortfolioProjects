SELECT  Location, MAX(Total_Deaths) as TotalDeathCount
FROM CovidDeaths
WHERE Location not REGEXP 'world|Europe|North America|European Union|South America|South America|Asia'
Group By Location 
ORDER By TotalDeathCount DESC

-- Lets breaking it up by continents 

SELECT  Continent, MAX(Total_Deaths) as TotalDeathCount
FROM CovidDeaths
WHERE Location not REGEXP 'World|Europe|North America|European Union|South America|Asia|Africa|International|Oceania' OR Location REGEXP 'South Africa'
Group By Continent 
ORDER By TotalDeathCount DESC

--Global Numbers
SELECT  date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location not REGEXP 'World|Europe|North America|European Union|South America|Asia|Africa|International|Oceania' OR Location REGEXP 'South Africa'
Group BY date
order by 1,2

SELECT   SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location not REGEXP 'World|Europe|North America|European Union|South America|Asia|Africa|International|Oceania' OR Location REGEXP 'South Africa'
order by 1,2


-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths Dea 
JOIN CovidVaccinations Vac 
ON Dea.Location=Vac.Location
AND Dea.Date=Vac.Date
WHERE dea.location not REGEXP 'World|Europe|North America|European Union|South America|Asia|Africa|International|Oceania' OR dea.Location REGEXP 'South Africa'
ORDER BY 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths Dea 
JOIN CovidVaccinations Vac 
ON Dea.Location=Vac.Location
AND Dea.Date=Vac.Date
WHERE dea.location not REGEXP 'World|Europe|North America|European Union|South America|Asia|Africa|International|Oceania' OR dea.Location REGEXP 'South Africa'
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent text,
Location text,
Date datetime,
population text,
New_vaccinations text,
RollingPeopleVaccinated text
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths Dea 
JOIN CovidVaccinations Vac 
ON Dea.Location=Vac.Location
AND Dea.Date=Vac.Date


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated


-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths Dea 
JOIN CovidVaccinations Vac 
ON Dea.Location=Vac.Location
AND Dea.Date=Vac.Date
WHERE dea.location not REGEXP 'World|Europe|North America|European Union|South America|Asia|Africa|International|Oceania' OR dea.Location REGEXP 'South Africa'
