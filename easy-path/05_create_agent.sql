/*=============================================================
  EASY PATH - Step 5: Create the Marketing Agent
  
  This script replaces the manual UI steps for creating
  the agent, adding tools, and configuring instructions.
  
  It creates a Cortex Agent with:
    - Cortex Analyst tool (semantic view)
    - Cortex Search tool (campaign search)
    - Custom tool (send_email procedure)
    - Data-to-chart visualization tool
    - Agent instructions and orchestration
=============================================================*/

USE ROLE SNOWFLAKE_INTELLIGENCE_ADMIN;
USE DATABASE DASH_DB_SI;
USE SCHEMA RETAIL;
USE WAREHOUSE DASH_WH_SI;

CREATE OR REPLACE AGENT MarketingAgent
  COMMENT = 'Marketing & Sales Intelligence Assistant'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  instructions:
    system: >
      I am a specialized Marketing & Sales Intelligence Assistant. My primary role
      is to provide accurate, data-driven insights by analyzing structured marketing
      metrics (spend, clicks, conversions) and unstructured customer feedback
      (support transcripts). I bridge the gap between what happened (the numbers)
      and why it happened (customer sentiment). Always maintain a professional,
      analytical tone and provide clear citations for information retrieved from
      support transcripts.
    orchestration: >
      Whenever you can answer visually with a chart, always choose to generate
      a chart even if the user did not specify to.
    sample_questions:
      - question: "What are the top 5 campaigns by clicks?"
      - question: "Show me all campaign performance metrics and it's relationship to the product"
      - question: "What is the relationship between campaign clicks and customer satisfaction by category?"
      - question: "What are the main customer complains in support cases?"

  tools:
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "AnalystTool"
        description: >
          Retail analytics semantic view in DASH_DB_SI.RETAIL connecting 6 tables:
          ENRICHED_MARKETING_INTELLIGENCE (campaign performance + sentiment),
          MARKETING_CAMPAIGN_METRICS (campaign KPIs by category/date),
          PRODUCTS (product catalog),
          SALES (sales transactions by region),
          SOCIAL_MEDIA (influencer mentions by platform/category),
          SUPPORT_CASES (customer support interactions).
          Key joins: ENRICHED_MARKETING_INTELLIGENCE.PRODUCT_NAME -> MARKETING_CAMPAIGN_METRICS.CATEGORY;
          PRODUCTS.PRODUCT_ID -> SALES.PRODUCT_ID.
          Enables end-to-end analysis from marketing exposure to sales performance to post-sale support.
    - tool_spec:
        type: "cortex_search"
        name: "Search"
        description: >
          Searches marketing campaign data including campaign names, categories,
          clicks, and impressions. Use this tool for finding specific campaigns
          or searching across campaign descriptions.
    - tool_spec:
        type: "data_to_chart"
        name: "data_to_chart"
        description: "Generates visualizations from data"
    - tool_spec:
        type: "generic"
        name: "Send_Email"
        description: >
          Sends an email using the Snowflake email integration. Use HTML syntax
          for the body. If content is in markdown, translate it to HTML. If body
          is not provided, summarize the last question and use that as content.
          If email is not provided, send to the current user. If subject is not
          provided, use 'Snowflake Intelligence'.
        input_schema:
          type: "object"
          properties:
            recipient_email:
              type: "string"
              description: "The recipient email address. If not provided, send to the current user's email."
            subject:
              type: "string"
              description: "The email subject. Defaults to 'Snowflake Intelligence' if not provided."
            body:
              type: "string"
              description: "The email body in HTML. If markdown, translate to HTML first."
          required:
            - recipient_email
            - subject
            - body

  tool_resources:
    AnalystTool:
      semantic_view: "DASH_DB_SI.RETAIL.SEMANTIC_VIEW"
    Search:
      name: "DASH_DB_SI.RETAIL.CAMPAIGN_SEARCH"
      max_results: "4"
      title_column: "CLICKS"
      id_column: "CAMPAIGN_NAME"
    Send_Email:
      type: "function"
      execution_environment:
        type: "warehouse"
        warehouse: "DASH_WH_SI"
      identifier: "DASH_DB_SI.RETAIL.SEND_EMAIL"
  $$;

DESCRIBE AGENT MarketingAgent;
