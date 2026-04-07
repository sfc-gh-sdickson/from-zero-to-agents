/*=============================================================
  EASY PATH - Step 6: Security - RBAC & Dynamic Data Masking
  
  This script replaces the manual steps in the
  "Security (optional)" section of the README.
  
  It performs:
    1. Creates a restricted marketing_intelligence_role
    2. Creates a secure view for restricted access
    3. Applies dynamic data masking on the clicks column
    4. Verifies masking works for both admin and restricted roles
=============================================================*/

-- ============================================================
-- Part A: Create the Marketing Role and Grant Access
-- ============================================================

USE ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
USE DATABASE DASH_DB_SI;
USE SCHEMA RETAIL;
USE WAREHOUSE DASH_WH_SI;

CREATE OR REPLACE SECURE VIEW marketing_intelligence_view AS
SELECT 
    campaign_name AS "Ad Campaign",
    category AS "Product Category",
    clicks AS "Engagement Clicks",
    0 AS "Customer Sentiment Score" 
FROM marketing_campaign_metrics;

-- Verify as admin (should see real numbers)
SELECT * FROM marketing_intelligence_view LIMIT 5;

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE ROLE marketing_intelligence_role;

GRANT USAGE ON WAREHOUSE dash_wh_si TO ROLE marketing_intelligence_role;
GRANT USAGE ON DATABASE dash_db_si TO ROLE marketing_intelligence_role;
GRANT USAGE ON SCHEMA dash_db_si.retail TO ROLE marketing_intelligence_role;
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE marketing_intelligence_role;
GRANT SELECT ON VIEW dash_db_si.retail.marketing_intelligence_view TO ROLE marketing_intelligence_role;

SET current_user = CURRENT_USER();
GRANT ROLE marketing_intelligence_role TO USER IDENTIFIER($CURRENT_USER);

-- ============================================================
-- Part B: Apply Dynamic Data Masking
-- ============================================================

USE ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
USE SCHEMA DASH_DB_SI.RETAIL;

CREATE OR REPLACE MASKING POLICY mask_engagement_clicks AS (val NUMBER) 
RETURNS NUMBER ->
  CASE 
    WHEN CURRENT_ROLE() IN ('SNOWFLAKE_INTELLIGENCE_ADMIN', 'ACCOUNTADMIN') THEN val 
    ELSE 0
  END;

ALTER TABLE marketing_campaign_metrics 
  MODIFY COLUMN clicks 
  SET MASKING POLICY mask_engagement_clicks;

-- Verify policy is active
SELECT * FROM TABLE(INFORMATION_SCHEMA.POLICY_REFERENCES(
    policy_name => 'mask_engagement_clicks'
));

-- ============================================================
-- Part C: Recreate the view (picks up table-level masking)
-- ============================================================

CREATE OR REPLACE SECURE VIEW marketing_intelligence_view AS
SELECT 
    campaign_name AS "Ad Campaign",
    category AS "Product Category",
    clicks AS "Engagement Clicks",
    0 AS "Customer Sentiment Score" 
FROM marketing_campaign_metrics;

-- ============================================================
-- Part D: Verify as Admin (should see real click numbers)
-- ============================================================

USE ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
USE SCHEMA DASH_DB_SI.RETAIL;
SELECT "Ad Campaign", "Engagement Clicks" FROM marketing_intelligence_view LIMIT 5;

-- ============================================================
-- Part E: Verify as Marketing Role (should see 0 for clicks)
-- ============================================================

USE ROLE MARKETING_INTELLIGENCE_ROLE;
USE SCHEMA DASH_DB_SI.RETAIL;
SELECT "Ad Campaign", "Engagement Clicks" FROM marketing_intelligence_view LIMIT 5;
