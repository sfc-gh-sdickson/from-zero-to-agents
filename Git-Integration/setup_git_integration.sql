/*=============================================================
  FROM ZERO TO AGENTS - Hands-On Lab
  GitHub Integration Setup (Run by Instructor / Admin)
  
  This script creates the API integration needed to connect
  Snowflake Workspaces to the public GitHub repository.
  
  PREREQUISITES:
  - Must be run by a role with CREATE INTEGRATION privilege
    (e.g., ACCOUNTADMIN)
=============================================================*/

-- Step 1: Create the API Integration for GitHub
CREATE OR REPLACE API INTEGRATION zero_to_agents_git_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-sdickson')
  ENABLED = TRUE;

-- Step 2: Grant USAGE to PUBLIC so all students can use this integration
GRANT USAGE ON INTEGRATION zero_to_agents_git_integration TO ROLE PUBLIC;

-- Step 3: Verify the integration
DESCRIBE INTEGRATION zero_to_agents_git_integration;
