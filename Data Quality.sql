SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'raw'
AND table_name = 'telco_staging'
ORDER BY ordinal_position;


SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(customerID) AS customerID_null,
    COUNT(*) - COUNT(gender) AS gender_null,
    COUNT(*) - COUNT(TotalCharges) AS TotalCharges_null,
    COUNT(*) - COUNT(Churn) AS Churn_null
FROM raw.telco_staging;


SELECT
    gender,
    COUNT(*) AS count
FROM raw.telco_staging
GROUP BY gender
ORDER BY count DESC;

SELECT
    Contract,
    COUNT(*) AS customers
FROM raw.telco_staging
GROUP BY Contract
ORDER BY customers DESC;