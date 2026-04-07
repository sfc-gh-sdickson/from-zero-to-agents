/*=============================================================
  EASY PATH - Step 2: Create Live Enrichment Pipeline
  
  This script replaces the manual steps in the
  "Create Live Enrichment Pipeline" section of the README.
  
  It creates a Dynamic Table that automatically joins campaign
  metrics with AI-generated sentiment scores from support cases.
=============================================================*/

USE ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
USE DATABASE DASH_DB_SI;
USE SCHEMA RETAIL;
USE WAREHOUSE DASH_WH_SI;

CREATE OR REPLACE DYNAMIC TABLE enriched_marketing_intelligence
  TARGET_LAG = '1 hours'
  WAREHOUSE = dash_wh_si
AS
SELECT 
    m.campaign_name,
    m.clicks,
    s.product AS product_name,
    SNOWFLAKE.CORTEX.SENTIMENT(s.transcript) AS avg_sentiment
FROM marketing_campaign_metrics m
JOIN support_cases s ON m.category = s.product;

-- Verify: preview the dynamic table
SELECT * FROM enriched_marketing_intelligence LIMIT 10;
