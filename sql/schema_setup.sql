-- ======================================================
-- B2B SaaS Customer Health & Revenue Leakage Database Setup
-- ======================================================

CREATE DATABASE IF NOT EXISTS saas_intelligence_db;
USE saas_intelligence_db;

-- 1. Dim_Companies Table
DROP TABLE IF EXISTS Fact_SupportTickets;
DROP TABLE IF EXISTS Fact_DailyUsage;
DROP TABLE IF EXISTS Dim_Subscriptions;
DROP TABLE IF EXISTS Dim_Companies;

CREATE TABLE Dim_Companies (
    company_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL,
    industry VARCHAR(50),
    company_size VARCHAR(20) -- Enterprise, Mid-Market, SMB
);

-- 2. Dim_Subscriptions Table
CREATE TABLE Dim_Subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    plan_name VARCHAR(50), -- Enterprise, Pro, Starter
    start_date DATE NOT NULL,
    arr DECIMAL(12, 2) NOT NULL,
    mrr DECIMAL(10, 2) NOT NULL,
    churn_status VARCHAR(20) DEFAULT 'Active', -- Active, Churned
    churn_date DATE NULL,
    churn_reason VARCHAR(100) NULL,
    FOREIGN KEY (company_id) REFERENCES Dim_Companies(company_id)
);

-- 3. Fact_DailyUsage Table
CREATE TABLE Fact_DailyUsage (
    usage_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    usage_date DATE NOT NULL,
    daily_active_users INT,
    feature_clicks INT,
    FOREIGN KEY (company_id) REFERENCES Dim_Companies(company_id)
);

-- 4. Fact_SupportTickets Table
CREATE TABLE Fact_SupportTickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    company_id INT NOT NULL,
    created_date DATE NOT NULL,
    priority VARCHAR(20), -- High, Medium, Low
    resolution_time_hrs DECIMAL(6, 2),
    csat_score DECIMAL(3, 2), -- 1.00 to 5.00
    FOREIGN KEY (company_id) REFERENCES Dim_Companies(company_id)
);

-- ======================================================
-- Mock Realistic Data Insertion (Aligned with Dashboard)
-- ======================================================

-- Insert Sample Companies
INSERT INTO Dim_Companies (company_id, company_name, industry, company_size) VALUES
(101, 'Apex Health Systems', 'Healthcare', 'Enterprise'),
(102, 'SecureNet Shield', 'Cybersecurity', 'Enterprise'),
(103, 'ShopNova Commerce', 'E-commerce', 'Mid-Market'),
(104, 'FinEdge Global', 'Fintech', 'Mid-Market'),
(105, 'SwiftFleet Logistics', 'Logistics', 'SMB'),
(106, 'LearnSphere Labs', 'Edtech', 'SMB'),
(107, 'CloudWave Tech', 'Cybersecurity', 'Mid-Market'),
(108, 'HealthPlus Clinics', 'Healthcare', 'SMB'),
(109, 'OmniRetail Hub', 'E-commerce', 'Enterprise'),
(110, 'PayPulse Systems', 'Fintech', 'Enterprise');

-- Insert Subscriptions
INSERT INTO Dim_Subscriptions (subscription_id, company_id, plan_name, start_date, arr, mrr, churn_status, churn_date, churn_reason) VALUES
(1, 101, 'Enterprise', '2025-01-15', 240000.00, 20000.00, 'Active', NULL, NULL),
(2, 102, 'Enterprise', '2025-02-01', 175000.00, 14583.33, 'Active', NULL, NULL),
(3, 103, 'Pro', '2025-03-10', 48000.00, 4000.00, 'Churned', '2025-08-20', 'Budget Cut'),
(4, 104, 'Pro', '2025-01-20', 60000.00, 5000.00, 'Active', NULL, NULL),
(5, 105, 'Starter', '2025-04-12', 12000.00, 1000.00, 'Churned', '2025-07-15', 'Competitor Switch'),
(6, 106, 'Starter', '2025-02-18', 15000.00, 1250.00, 'Churned', '2025-06-10', 'Poor Support Response'),
(7, 107, 'Pro', '2025-05-01', 55000.00, 4583.33, 'Churned', '2025-09-05', 'Low Feature Adoption'),
(8, 108, 'Starter', '2025-03-01', 18000.00, 1500.00, 'Churned', '2025-08-14', 'Price Hike'),
(9, 109, 'Enterprise', '2025-01-05', 210000.00, 17500.00, 'Active', NULL, NULL),
(10, 110, 'Enterprise', '2025-02-15', 190000.00, 15833.33, 'Active', NULL, NULL);

-- Insert Support Tickets
INSERT INTO Fact_SupportTickets (company_id, created_date, priority, resolution_time_hrs, csat_score) VALUES
(101, '2025-07-10', 'Medium', 12.5, 4.5),
(102, '2025-07-22', 'Low', 6.0, 4.8),
(103, '2025-08-01', 'High', 48.0, 2.0),
(104, '2025-08-11', 'Medium', 18.0, 3.8),
(105, '2025-07-02', 'High', 36.0, 2.2),
(106, '2025-05-25', 'High', 72.0, 1.5),
(107, '2025-08-19', 'Medium', 24.0, 2.5),
(108, '2025-07-30', 'Low', 14.0, 2.3),
(109, '2025-06-15', 'Low', 8.0, 4.7),
(110, '2025-07-18', 'Medium', 15.0, 4.2);

-- Insert Daily Usage
INSERT INTO Fact_DailyUsage (company_id, usage_date, daily_active_users, feature_clicks) VALUES
(101, '2025-08-01', 120, 1450),
(102, '2025-08-01', 85, 920),
(103, '2025-08-01', 12, 85),
(104, '2025-08-01', 45, 420),
(105, '2025-07-01', 5, 24),
(106, '2025-05-20', 3, 15),
(107, '2025-08-15', 8, 65),
(108, '2025-07-20', 4, 30),
(109, '2025-08-01', 140, 1800),
(110, '2025-08-01', 110, 1350);