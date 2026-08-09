/* =========================================
   1. OVERVIEW & BASIC EXPLORATION
========================================= */
-- ตัวอย่างข้อมูล
SELECT * FROM analytics.telco_customers LIMIT 10;

-- จำนวนข้อมูลทั้งหมด 
SELECT COUNT(*) AS total_customer FROM analytics.telco_customers;

-- เราอยากรู้ว่า gender แต่ละค่ามีกี่คน
SELECT gender, COUNT(*) AS total_customer
FROM analytics.telco_customers
GROUP BY gender;

/* =========================================
   2. TARGET VARIABLE (CHURN) ANALYSIS
========================================= */
-- Analysis 1 — Churn Rate
SELECT Churn, COUNT(*) AS customers,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage 
FROM analytics.telco_customers
GROUP BY Churn;

/* =========================================
   3. PRODUCT & CONTRACT ANALYSIS
========================================= */
-- Analysis 2  Churn ตาม Contract
SELECT Contract, COUNT(*) AS customers,
       SUM(CASE WHEN Churn= 'Yes' THEN 1 ELSE 0 END) AS churned,
       ROUND(SUM(CASE WHEN Churn= 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM analytics.telco_customers
GROUP BY Contract;

-- Analysis ต่อไป: Internet Service
SELECT DISTINCT InternetService FROM analytics.telco_customers;

SELECT InternetService, COUNT(*) AS customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
       ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM analytics.telco_customers
GROUP BY InternetService
ORDER BY churn_rate DESC;
-- Fiber optic มี Churn Rate สูงที่สุดในกลุ่ม InternetService 41.89 %

SELECT Contract, COUNT(*) AS customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
       ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM analytics.telco_customers
WHERE InternetService = 'Fiber optic'
GROUP BY Contract
ORDER BY churn_rate DESC;
-- Fiber optic + Month-to-month → 54.61% Churn Rate

-- สลับมาดูบริการทั้งหมดของ internet
SELECT InternetService, Contract, COUNT(*) AS customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
       ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM analytics.telco_customers
GROUP BY InternetService, Contract
ORDER BY Contract ASC;
-- ลูกค้าแบบ Month-to-month มี Churn Rate สูงในทุกประเภท InternetService

/* =========================================
   4. TENURE & PRICE ANALYSIS
========================================= */
-- ลองมาดู tenure แต่ละกลุ่ม
SELECT 
    CASE 
        WHEN tenure BETWEEN 0 AND 12 THEN '1. 0–12 months (Awareness)'
        WHEN tenure BETWEEN 13 AND 24 THEN '2. 13–24 months (Consideration)'
        WHEN tenure BETWEEN 25 AND 48 THEN '3. 25–48 months (Purchase)'
        WHEN tenure >= 49 THEN '4. 49+ months (Retention)'
        ELSE 'Unknown'
    END AS "กลุ่มอายุการใช้งาน (Tenure Group)",
    COUNT(*) AS "จำนวนลูกค้าทั้งหมด (Total)",
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS "จำนวนลูกค้ายกเลิก (Churned)",
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS "อัตราการยกเลิก (Churn Rate %)"
FROM analytics.telco_customers
GROUP BY 1 ORDER BY 1;

SELECT 
    CASE 
        WHEN MonthlyCharges < 50 THEN 'Low (< $50)'
        WHEN MonthlyCharges BETWEEN 50 AND 80 THEN 'Medium ($50 - $80)'
        ELSE 'High (> $80)' 
    END AS Charge_Bucket,
    COUNT(*) as total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM analytics.telco_customers
WHERE InternetService = 'Fiber optic' AND Contract = 'Month-to-month'
GROUP BY 1 ORDER BY churn_rate DESC;

-- จากนั้นมาทำการวิเคราะห์กลุ่ม Higth ว่า > 80 ที่จ่ายได้รวมบริการอื่นรวมหรือไม่
SELECT 
    CASE 
        WHEN MonthlyCharges < 50 THEN 'Low (< $50)'
        WHEN MonthlyCharges BETWEEN 50 AND 80 THEN 'Medium ($50 - $80)'
        ELSE 'High (> $80)' 
    END AS charge_bucket,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN TechSupport = 'Yes' THEN 1 ELSE 0 END) AS tech_support_users,
    ROUND(SUM(CASE WHEN TechSupport = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS tech_support_pct,
    SUM(CASE WHEN OnlineSecurity = 'Yes' THEN 1 ELSE 0 END) AS online_security_users,
    ROUND(SUM(CASE WHEN OnlineSecurity = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS online_security_pct,
    SUM(CASE WHEN StreamingTV = 'Yes' THEN 1 ELSE 0 END) AS streaming_tv_users,
    ROUND(SUM(CASE WHEN StreamingTV = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS streaming_tv_pct
FROM analytics.telco_customers
WHERE InternetService = 'Fiber optic' AND Contract = 'Month-to-month'
GROUP BY 1 ORDER BY charge_bucket DESC;

/* =========================================
   5. PAYMENT & DEMOGRAPHICS (THE PERFECT STORM)
========================================= */
SELECT PaymentMethod, COUNT(*) AS total_customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
       ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM analytics.telco_customers
GROUP BY PaymentMethod
ORDER BY churn_rate DESC;

-- หลังจากรู้รายละเอียดข้อมูลภายนอกแล้วเราต้องมาดูข้อมูลภายในต่อ 
SELECT Partner, Dependents, COUNT(*) AS total_customers,
       SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
       ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM analytics.telco_customers
GROUP BY Partner, Dependents
ORDER BY churn_rate DESC;