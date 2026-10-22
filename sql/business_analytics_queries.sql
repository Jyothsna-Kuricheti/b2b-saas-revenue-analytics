-- ======================================================
-- B2B SaaS Business & Revenue Leakage Analytics
-- Database: saas_intelligence_db
-- ======================================================

USE saas_intelligence_db;

-- ------------------------------------------------------
-- Query 1: Month-over-Month (MoM) Churn & Revenue Movement
-- Highlights: CTEs, Window Functions (LAG), Cohort Logic
-- ------------------------------------------------------
WITH MonthlyMetrics AS (
    SELECT 
        DATE_FORMAT(start_date, '%Y-%m') AS subscription_month,
        COUNT(DISTINCT company_id) AS total_joined,
        COUNT(DISTINCT CASE WHEN churn_status = 'Churned' THEN company_id END) AS total_churned,
        SUM(mrr) AS total_mrr
    FROM Dim_Subscriptions
    GROUP BY DATE_FORMAT(start_date, '%Y-%m')
)
SELECT 
    subscription_month,
    total_joined,
    total_churned,
    total_mrr,
    LAG(total_mrr, 1) OVER (ORDER BY subscription_month) AS prev_month_mrr,
    ROUND((total_churned * 100.0) / NULLIF(total_joined, 0), 2) AS churn_rate_pct,
    ROUND(
        ((total_mrr - LAG(total_mrr, 1) OVER (ORDER BY subscription_month)) * 100.0) 
        / NULLIF(LAG(total_mrr, 1) OVER (ORDER BY subscription_month), 0), 2
    ) AS mom_mrr_growth_pct
FROM MonthlyMetrics
ORDER BY subscription_month;


-- ------------------------------------------------------
-- Query 2: Root Cause Churn Drivers & Lost ARR Financial Impact
-- Highlights: Aggregations, Window Functions (OVER())
-- ------------------------------------------------------
SELECT 
    churn_reason,
    COUNT(DISTINCT company_id) AS churned_accounts,
    ROUND(SUM(arr), 2) AS total_arr_lost,
    ROUND(AVG(mrr), 2) AS avg_lost_mrr_per_client,
    ROUND(
        (COUNT(DISTINCT company_id) * 100.0) / SUM(COUNT(DISTINCT company_id)) OVER(), 2
    ) AS pct_of_total_churns
FROM Dim_Subscriptions
WHERE churn_status = 'Churned'
GROUP BY churn_reason
ORDER BY total_arr_lost DESC;


-- ------------------------------------------------------
-- Query 3: Plan Tier Performance & Revenue Concentration
-- Highlights: Contribution Share Calculation
-- ------------------------------------------------------
SELECT 
    plan_name,
    COUNT(DISTINCT company_id) AS total_accounts,
    ROUND(SUM(arr), 2) AS total_arr,
    ROUND(AVG(arr), 2) AS avg_arr_per_account,
    ROUND(
        (SUM(arr) * 100.0) / SUM(SUM(arr)) OVER(), 2
    ) AS arr_contribution_pct
FROM Dim_Subscriptions
GROUP BY plan_name
ORDER BY total_arr DESC;


-- ------------------------------------------------------
-- Query 4: Churn Risk Early Warning View (Data Feed to GenAI Copilot)
-- Highlights: Multi-Table Joins, Grouping, HAVING Filters
-- ------------------------------------------------------
CREATE OR REPLACE VIEW vw_high_risk_accounts AS
SELECT 
    c.company_id,
    c.company_name,
    c.industry,
    c.company_size,
    s.plan_name,
    s.mrr,
    s.arr,
    ROUND(AVG(st.csat_score), 2) AS avg_csat,
    COUNT(st.ticket_id) AS total_tickets_raised
FROM Dim_Companies c
JOIN Dim_Subscriptions s ON c.company_id = s.company_id
LEFT JOIN Fact_SupportTickets st ON c.company_id = st.company_id
WHERE s.churn_status = 'Active'
GROUP BY c.company_id, c.company_name, c.industry, c.company_size, s.plan_name, s.mrr, s.arr
HAVING avg_csat < 3.0 OR total_tickets_raised >= 3;

-- Verification
SELECT * FROM vw_high_risk_accounts;