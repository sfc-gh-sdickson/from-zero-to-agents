/*=============================================================
  EASY PATH - Step 4: Cortex Search Service
  
  This script replaces the manual UI steps for creating
  a Cortex Search Service in the README.
  
  It creates a search service on the MARKETING_CAMPAIGN_METRICS
  table with CAMPAIGN_NAME as the search column.
=============================================================*/

USE ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
USE DATABASE DASH_DB_SI;
USE SCHEMA RETAIL;
USE WAREHOUSE DASH_WH_SI;

CREATE OR REPLACE CORTEX SEARCH SERVICE campaign_search
  ON campaign_name
  ATTRIBUTES category, clicks, impressions, date
  WAREHOUSE = DASH_WH_SI
  TARGET_LAG = '1 hour'
  AS (
    SELECT
      campaign_name,
      category,
      clicks,
      impressions,
      date
    FROM marketing_campaign_metrics
  );

-- Verify: check the service is created
SHOW CORTEX SEARCH SERVICES IN SCHEMA DASH_DB_SI.RETAIL;
