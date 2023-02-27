/*
Covid 19 Data Exploration 
Skills used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


Select *
From Portfolio_Project..Covid_Deaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..Covid_Deaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths per day

Select Location, date, total_cases,total_deaths, (Cast(total_deaths as decimal(12,0))/total_cases)*100 as DeathPercentage
From Portfolio_Project..Covid_Deaths
Where location like '%states%'
and continent is not null 
order by DeathPercentage desc


-- Total Cases vs Population per day

Select Location, date, Population, total_cases, 
left(cast(total_cases as decimal(12,0))/population*100,5) as PercentPopulationInfected
From Portfolio_Project..Covid_Deaths
order by PercentPopulationInfected desc


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, 
Max(left(cast(total_cases as decimal(12,0))/population*100,5)) as PercentPopulationInfected
From Portfolio_Project..Covid_Deaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location,population,MAX(Total_deaths) as Total_DeathCount
From Portfolio_Project..Covid_Deaths
Where continent is not null 
Group by Location,population
order by Total_DeathCount desc

-- Contintents with the highest death count per population

Select continent, MAX(Total_deaths) as Total_Deaths
From Portfolio_Project..Covid_Deaths
Where continent is not null 
Group by continent
order by Total_Deaths desc


-- Average New Deaths Per Day Per Country

Select Location, AVG(new_deaths) as AvgDeathsperDay
from Covid_Deaths
Where continent is not null 
Group by location 
Order by AvgDeathsperDay desc


-- A look at GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as decimal(12,0)))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project..Covid_Deaths
where continent is not null 
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select d.continent,d.location,d.population,d.date,v.new_vaccinations as New_Vaccinations_Daily,
Sum(new_vaccinations) Over (partition by d.location order by d.date,d.location) as Rolling_Vaccination_Count
from Portfolio_Project..Covid_Deaths d 
Join Portfolio_Project..Covid_Vaccinations v on d.location = v.location
and d.date = v.date
Where d.continent is not null
--Group by d.continent,d.location,d.population,d.date
Order by 2,4



-- Creating Views 

Create View Total_People_Vaccinated as
select d.continent,d.location,d.population,d.date,v.new_vaccinations as New_Vaccinations_Daily,
Sum(new_vaccinations) Over (partition by d.location order by d.date,d.location) as Rolling_Vaccination_Count
from Portfolio_Project..Covid_Deaths d 
Join Portfolio_Project..Covid_Vaccinations v on d.location = v.location
and d.date = v.date
Where d.continent is not null
--Group by d.continent,d.location,d.population,d.date
--Order by 2,4



-- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vaccination_Count)
as
(select d.continent,d.location,d.population,d.date,v.new_vaccinations as New_Vaccinations_Daily,
Sum(new_vaccinations) Over (partition by d.location order by d.date,d.location) as Rolling_Vaccination_Count
from Portfolio_Project..Covid_Deaths d 
Join Portfolio_Project..Covid_Vaccinations v on d.location = v.location
and d.date = v.date
Where d.continent is not null
--Group by d.continent,d.location,d.population,d.date
--Order by 2,4
)
Select *, (Rolling_Vaccination_Count)/Population)*100
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
Rolling_Vaccination_Count numeric
)

Insert into #PercentPopulationVaccinated
select d.continent,d.location,d.population,d.date,v.new_vaccinations as New_Vaccinations_Daily,
Sum(new_vaccinations) Over (partition by d.location order by d.date,d.location) as Rolling_Vaccination_Count
from Portfolio_Project..Covid_Deaths d 
Join Portfolio_Project..Covid_Vaccinations v on d.location = v.location
and d.date = v.date
Where d.continent is not null
--Group by d.continent,d.location,d.population,d.date
--Order by 2,4
Select *, (Rolling_Vaccination_Count/Population)*100
From #PercentPopulationVaccinated
