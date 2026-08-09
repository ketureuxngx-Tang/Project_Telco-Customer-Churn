SELECT *
FROM raw.telco_staging
LIMIT 10;

SELECT COUNT(*)
FROM raw.telco_staging;

SELECT COUNT(*)
FROM information_schema.columns
WHERE table_schema = 'raw'
AND table_name = 'telco_staging';