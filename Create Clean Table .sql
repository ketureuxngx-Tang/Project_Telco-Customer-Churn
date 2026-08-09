CREATE TABLE analytics.telco_customers AS
SELECT
    customerID,
    gender,
    CAST(SeniorCitizen AS INTEGER) AS SeniorCitizen,
    Partner,
    Dependents,
    CAST(tenure AS INTEGER) AS tenure,
    PhoneService,
    MultipleLines,
    InternetService,
    OnlineSecurity,
    OnlineBackup,
    DeviceProtection,
    TechSupport,
    StreamingTV,
    StreamingMovies,
    Contract,
    PaperlessBilling,
    PaymentMethod,
    CAST(MonthlyCharges AS NUMERIC(10,2)) AS MonthlyCharges,
    NULLIF(TRIM(TotalCharges), '')::NUMERIC(10,2) AS TotalCharges,
    Churn
FROM raw.telco_staging;