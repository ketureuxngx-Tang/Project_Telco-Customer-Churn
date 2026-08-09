SELECT *
FROM analytics.telco_customers
LIMIT 10;

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'analytics'
AND table_name = 'telco_customers';


SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(customerID) AS missing_customerID,
    COUNT(*) - COUNT(gender) AS missing_gender,
    COUNT(*) - COUNT(tenure) AS missing_tenure,
    COUNT(*) - COUNT(MonthlyCharges) AS missing_monthly,
    COUNT(*) - COUNT(TotalCharges) AS missing_total,
    COUNT(*) - COUNT(Churn) AS missing_churn
FROM analytics.telco_customers;