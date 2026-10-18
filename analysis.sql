-- =============================================
-- Cookie Cats A/B Test -- SQL Analysis
-- Author: Aryan Joshi
-- Dataset: 90,189 mobile game players
-- Tool: MySQL
-- =============================================

USE ab_testing;

-- =============================================
-- Q1: Core retention comparison between groups
-- Compares Day 1 and Day 7 retention rates
-- between control (gate_30) and treatment (gate_40)
-- =============================================
SELECT 
    version,
    COUNT(*) AS total_users,
    SUM(CASE WHEN retention_1 = 'TRUE' THEN 1 ELSE 0 END) AS retained_day1,
    ROUND(100.0 * SUM(CASE WHEN retention_1 = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*), 2) AS day1_retention_pct,
    SUM(CASE WHEN retention_7 = 'TRUE' THEN 1 ELSE 0 END) AS retained_day7,
    ROUND(100.0 * SUM(CASE WHEN retention_7 = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*), 2) AS day7_retention_pct
FROM cookie_cats
GROUP BY version;

-- =============================================
-- Q2: Funnel drop-off by engagement level
-- Segments users into engagement buckets
-- to identify where players are dropping off
-- =============================================
SELECT 
    version,
    COUNT(*) AS total_users,
    SUM(CASE WHEN sum_gamerounds = 0 THEN 1 ELSE 0 END) AS never_played,
    SUM(CASE WHEN sum_gamerounds BETWEEN 1 AND 10 THEN 1 ELSE 0 END) AS early_dropoff,
    SUM(CASE WHEN sum_gamerounds > 10 THEN 1 ELSE 0 END) AS engaged_users
FROM cookie_cats
GROUP BY version;

-- =============================================
-- Q3: Cohort retention breakdown
-- Day 7 retention rate broken down by
-- engagement cohort and test group
-- =============================================
SELECT
    version,
    CASE 
        WHEN sum_gamerounds = 0 THEN '1_zero_rounds'
        WHEN sum_gamerounds BETWEEN 1 AND 10 THEN '2_early_1to10'
        WHEN sum_gamerounds BETWEEN 11 AND 40 THEN '3_mid_11to40'
        ELSE '4_engaged_40plus'
    END AS cohort,
    COUNT(*) AS users,
    ROUND(100.0 * SUM(CASE WHEN retention_7 = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*), 2) AS day7_retention_pct
FROM cookie_cats
GROUP BY version, cohort
ORDER BY version, cohort;