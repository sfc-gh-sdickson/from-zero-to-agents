/*=============================================================
  EASY PATH - Step 3: Semantic Layer (Semantic View)
  
  This script replaces the manual UI steps for creating a
  Semantic View via the Cortex Analyst Autopilot wizard.
  
  It creates the semantic view via SQL with:
    - All 5 base tables + 1 dynamic table
    - Dimensions and metrics for querying
    - Relationship: ENRICHED_MARKETING_INTELLIGENCE -> MARKETING_CAMPAIGN_METRICS
    - Relationship: PRODUCTS -> SALES
=============================================================*/

USE ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
USE DATABASE DASH_DB_SI;
USE SCHEMA RETAIL;
USE WAREHOUSE DASH_WH_SI;

CREATE OR REPLACE SEMANTIC VIEW SEMANTIC_VIEW

  TABLES (
    marketing_campaign_metrics AS DASH_DB_SI.RETAIL.MARKETING_CAMPAIGN_METRICS
      PRIMARY KEY (CATEGORY)
      COMMENT = 'Campaign KPIs by category and date',

    products AS DASH_DB_SI.RETAIL.PRODUCTS
      PRIMARY KEY (PRODUCT_ID)
      COMMENT = 'Product catalog',

    sales AS DASH_DB_SI.RETAIL.SALES
      PRIMARY KEY (DATE, REGION, PRODUCT_ID)
      COMMENT = 'Sales transactions by region',

    social_media AS DASH_DB_SI.RETAIL.SOCIAL_MEDIA
      PRIMARY KEY (DATE, CATEGORY, PLATFORM, INFLUENCER)
      COMMENT = 'Influencer mentions by platform and category',

    support_cases AS DASH_DB_SI.RETAIL.SUPPORT_CASES
      PRIMARY KEY (ID)
      COMMENT = 'Customer support interactions',

    enriched_marketing_intelligence AS DASH_DB_SI.RETAIL.ENRICHED_MARKETING_INTELLIGENCE
      COMMENT = 'Campaign performance enriched with sentiment'
  )

  RELATIONSHIPS (
    enriched_to_marketing AS
      enriched_marketing_intelligence (PRODUCT_NAME) REFERENCES marketing_campaign_metrics (CATEGORY),
    sales_to_products AS
      sales (PRODUCT_ID) REFERENCES products (PRODUCT_ID)
  )

  DIMENSIONS (
    marketing_campaign_metrics.campaign_date AS DATE
      COMMENT = 'Date of campaign metrics',
    marketing_campaign_metrics.category_dim AS CATEGORY
      COMMENT = 'Product category',
    marketing_campaign_metrics.campaign_name_dim AS CAMPAIGN_NAME
      COMMENT = 'Name of the campaign',

    products.product_name_dim AS PRODUCT_NAME
      COMMENT = 'Product name',
    products.product_category_dim AS CATEGORY
      COMMENT = 'Product category',

    sales.sale_date AS DATE
      COMMENT = 'Date of sale',
    sales.region_dim AS REGION
      COMMENT = 'Sales region',

    social_media.social_date AS DATE
      COMMENT = 'Date of social media mention',
    social_media.platform_dim AS PLATFORM
      COMMENT = 'Social media platform',
    social_media.influencer_dim AS INFLUENCER
      COMMENT = 'Influencer name',
    social_media.social_category_dim AS CATEGORY
      COMMENT = 'Product category for social mentions',

    support_cases.case_title_dim AS TITLE
      COMMENT = 'Support case title',
    support_cases.case_product_dim AS PRODUCT
      COMMENT = 'Product referenced in support case',
    support_cases.case_date AS DATE
      COMMENT = 'Date of support case',

    enriched_marketing_intelligence.enriched_campaign_name AS CAMPAIGN_NAME
      COMMENT = 'Campaign name from enriched data',
    enriched_marketing_intelligence.enriched_product_name AS PRODUCT_NAME
      COMMENT = 'Product name from enriched data'
  )

  METRICS (
    marketing_campaign_metrics.total_impressions AS SUM(IMPRESSIONS)
      COMMENT = 'Total campaign impressions',
    marketing_campaign_metrics.total_clicks AS SUM(CLICKS)
      COMMENT = 'Total campaign clicks',
    marketing_campaign_metrics.avg_clicks AS AVG(CLICKS)
      COMMENT = 'Average clicks per campaign',

    sales.total_units_sold AS SUM(UNITS_SOLD)
      COMMENT = 'Total units sold',
    sales.total_sales_amount AS SUM(SALES_AMOUNT)
      COMMENT = 'Total sales revenue',
    sales.avg_sales_amount AS AVG(SALES_AMOUNT)
      COMMENT = 'Average sale amount',

    social_media.total_mentions AS SUM(MENTIONS)
      COMMENT = 'Total social media mentions',

    enriched_marketing_intelligence.avg_sentiment AS AVG(AVG_SENTIMENT)
      COMMENT = 'Average customer sentiment score',
    enriched_marketing_intelligence.enriched_total_clicks AS SUM(CLICKS)
      COMMENT = 'Total clicks from enriched data'
  )

  COMMENT = 'Retail analytics semantic view connecting campaign metrics, products, sales, social media, support cases, and enriched marketing intelligence.';

DESCRIBE SEMANTIC VIEW SEMANTIC_VIEW;
