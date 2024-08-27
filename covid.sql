CREATE TABLE IF NOT EXISTS covid (
    iso_code VARCHAR(30) NOT NULL,
    continent VARCHAR(30),
    location VARCHAR(50) NOT NULL,
    date DATE NOT NULL,
    total_cases BIGINT,
    new_cases BIGINT,
    total_deaths BIGINT,
    new_deaths BIGINT,
    icu_patients BIGINT,
    hosp_patients BIGINT,
    weekly_hosp_admission DECIMAL(12, 4),
    weekly_icu_admission NUMERIC(15, 4)
);
--total case vs total death to show the likelihood of dying if you get covid in japan
SELECT location,
    date,
    total_cases,
    total_deaths,
    ROUND(
        (
            (total_deaths::NUMERIC / total_cases::NUMERIC) * 100
        ),
        2
    ) AS death_ratio
FROM covid
WHERE location = 'Japan'
    AND continent IS NOT NULL;
--highest death rate 
SELECT location,
    total_deaths,
    total_cases,
    (total_deaths::NUMERIC / total_cases::NUMERIC) * 100 AS death_ratio
FROM covid
WHERE continent IS NOT NULL
ORDER BY death_ratio DESC NULLS LAST;
--highest death count by country
SELECT location,
    MAX(total_deaths) AS death_count
FROM covid
WHERE total_deaths IS NOT NULL
    AND continent IS NOT NULL
GROUP BY location
ORDER BY death_count DESC;
--highest death count by continent 
SELECT location,
    MAX(total_deaths) AS death_count
FROM covid
WHERE total_deaths IS NOT NULL
    AND continent IS NULL
GROUP BY location
ORDER BY death_count DESC;
--global numbers by date
SELECT date,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS death_percentage
FROM covid
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;
--total numbers
SELECT SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_deaths) / SUM(new_cases) * 100 AS death_percentage
FROM covid
WHERE continent IS NOT NULL;
--new table
CREATE TABLE IF NOT EXISTS vaccine (
    iso_code VARCHAR(30) NOT NULL,
    continent VARCHAR(30),
    location VARCHAR(50) NOT NULL,
    date DATE NOT NULL,
    new_test BIGINT,
    total_test BIGINT,
    positive_rate NUMERIC(15, 5),
    tests_per_case NUMERIC(15, 5),
    tests_units VARCHAR(30),
    total_vaccination BIGINT,
    people_vaccinated BIGINT,
    people_fully_vaccinated BIGINT,
    new_vaccinations BIGINT,
    stringency_index NUMERIC(15, 5),
    population_density NUMERIC(15, 5),
    median_age NUMERIC(15, 5),
    age_65_older NUMERIC(15, 5),
    age_70_older NUMERIC(15, 5),
    gdp_per_capita NUMERIC(15, 5),
    extreme_poverty NUMERIC(15, 5),
    cardiovasc_death_rate NUMERIC(15, 5),
    diabetes_prevalence NUMERIC(15, 5),
    female_smoker NUMERIC(15, 5),
    male_smoker NUMERIC(15, 5),
    handwashing_facilities NUMERIC(15, 5),
    life_expectancy NUMERIC(15, 5),
    human_development_index NUMERIC(15, 5)
);
--total global number of vaccinated people
SELECT covid.date,
    SUM(vaccine.people_vaccinated)
FROM covid
    JOIN vaccine ON covid.location = vaccine.location
    AND covid.date = vaccine.date
GROUP BY covid.date
ORDER BY covid.date;
--number of vaccinated people by country
SELECT co.location,
    co.date,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        PARTITION BY co.location
        ORDER BY co.location,
            co.date
    ) AS accumulated_new_vaccination
FROM covid co
    JOIN vaccine vac ON co.location = vac.location
    AND co.date = vac.date
WHERE co.continent IS NOT NULL
GROUP BY co.location,
    co.date,
    vac.new_vaccinations
ORDER BY co.location;
--use CTE
WITH use_cte AS (
    SELECT co.continent,
        co.location,
        co.date,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (
            PARTITION BY co.location
            ORDER BY co.date
        ) AS accumulated_new_vaccination
    FROM covid co
        JOIN vaccine vac ON co.location = vac.location
        AND co.date = vac.date
    WHERE co.continent IS NOT NULL
)
SELECT *
FROM use_cte;