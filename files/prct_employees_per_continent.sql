-- percentage of employees per continent
SELECT
  hr_countries.Continent,
  COUNT(DISTINCT t0.uid_employees) AS num_employees,
  (COUNT(DISTINCT t0.uid_employees) * 100.0) / (
  SELECT
    COUNT(*)
  FROM
    `iaac-gcp-data-mgt`.`DOMAIN_HR`.`hr_employees_list`) AS percentage
FROM
  `iaac-gcp-data-mgt`.`DOMAIN_HR`.`hr_employees_list` AS t0
INNER JOIN
  `iaac-gcp-data-mgt`.`DOMAIN_HR`.`hr_countries` AS hr_countries
ON
  t0.country = hr_countries.country
GROUP BY
  1;