/*=============================================================
  EASY PATH - Step 1: AI Enrichment with Cortex AI
  
  This script replaces the manual steps in the
  "AI Enrichment with Cortex AI" section of the README.
  
  It performs:
    1. Fixes product naming inconsistency
    2. Runs sentiment analysis and classification on support cases
    3. Loads updated marketing data from the workspace CSV
=============================================================*/

USE ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
USE DATABASE DASH_DB_SI;
USE SCHEMA RETAIL;
USE WAREHOUSE DASH_WH_SI;

-- Fix product naming inconsistency
UPDATE support_cases SET product = 'Fitness Wear' WHERE product = 'ThermoJacket Pro';

-- Extract trends: sentiment + classification on support transcripts
SELECT 
    title,
    SNOWFLAKE.CORTEX.AI_SENTIMENT(transcript) AS sentiment_score,
    SNOWFLAKE.CORTEX.AI_CLASSIFY(transcript, ['Return', 'Quality', 'Shipping']) AS issue_category
FROM support_cases;

-- Load updated marketing data from workspace CSV
-- Step 1: Create a temp stage and file format for the workspace file
CREATE OR REPLACE TEMPORARY STAGE marketing_upload_stage
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

CREATE OR REPLACE TEMPORARY FILE FORMAT marketing_upload_csv
  TYPE = 'CSV'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- Step 2: Copy the workspace CSV file into the temp stage
COPY FILES INTO @marketing_upload_stage
  FROM 'snow://workspace/USER$.PUBLIC."from-zero-to-agents"/versions/live/'
  FILES = ('assets/marketing_data.csv');

-- Step 3: Load the CSV data into the marketing table
COPY INTO marketing_campaign_metrics
  FROM @marketing_upload_stage/assets/marketing_data.csv
  FILE_FORMAT = marketing_upload_csv
  ON_ERROR = 'CONTINUE';

-- Verify: show row count after load
SELECT COUNT(*) AS total_marketing_rows FROM marketing_campaign_metrics;
