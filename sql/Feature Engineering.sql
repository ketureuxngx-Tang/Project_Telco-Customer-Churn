-- สร้าง View สำหรับส่งเข้า Python เพื่อทำ Machine Learning
CREATE VIEW analytics.ml_features AS
SELECT 
    customerID,
    gender,
    SeniorCitizen,
    Partner,
    Dependents,
    tenure,
    InternetService,
    Contract,
    PaymentMethod,
    MonthlyCharges,
    TotalCharges,
    
    -- Feature 1: Label Encoding (แปลงเป้าหมายเป็น 1/0)
    CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END AS is_churned,
    
    -- Feature 2: Tenure Group (จัดกลุ่มตามที่ EDA พบ)
    CASE 
        WHEN tenure <= 12 THEN '0_12_months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13_24_months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25_48_months'
        ELSE 'over_48_months'
    END AS tenure_group,
    
    -- Feature 3: Charge Bucket
    CASE 
        WHEN MonthlyCharges < 50 THEN 'Low'
        WHEN MonthlyCharges BETWEEN 50 AND 80 THEN 'Medium'
        ELSE 'High' 
    END AS charge_bucket,
    
    -- Feature 4: Risk Score เบื้องต้น
    (
        CASE WHEN Contract = 'Month-to-month' THEN 2 ELSE 0 END +
        CASE WHEN InternetService = 'Fiber optic' THEN 1 ELSE 0 END +
        CASE WHEN PaymentMethod = 'Electronic check' THEN 1 ELSE 0 END +
        CASE WHEN Partner = 'No' AND Dependents = 'No' THEN 1 ELSE 0 END
    ) AS baseline_risk_score

FROM analytics.telco_customers;
