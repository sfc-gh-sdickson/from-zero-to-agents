<img src="../Snowflake_Logo.svg" width="200">

# From Zero to Agents - Workspace Setup Guide

## Overview

This guide walks you through creating a **read-only Snowflake Workspace** connected to the hands-on lab GitHub repository. The workspace syncs files from the repo directly into Snowsight so you can run code without cloning anything locally.

---

## Part 1: ACCOUNTADMIN Setup (One-Time)

> **Accountadmin needs to perform this step.** 

### 1.1 Create the API Integration

Run the following SQL in a Snowflake worksheet using the **ACCOUNTADMIN** role:

```sql
-- Create the API integration for GitHub
CREATE OR REPLACE API INTEGRATION zero_to_agents_git_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-sdickson')
  ENABLED = TRUE;

-- Grant USAGE to PUBLIC so all students can use this integration
GRANT USAGE ON INTEGRATION zero_to_agents_git_integration TO ROLE PUBLIC;
```

### 1.2 Verify

```sql
DESCRIBE INTEGRATION zero_to_agents_git_integration;
```

You should see the integration details with `ENABLED = true`.

---

## Part 2: Student Setup (Each Student Follows These Steps)

### Step 1 — Open Workspaces

1. Sign in to **Snowsight** (your Snowflake web UI).
2. In the left navigation menu, select **Projects** → **Workspaces**.

### Step 2 — Create a New Git Workspace

1. Click the **Workspaces** dropdown menu (or the **+** button).
2. Select **From Git repository**.

### Step 3 — Enter the Repository URL

1. In the **Repository URL** field, paste:
   ```
   https://github.com/sfc-gh-sdickson/from-zero-to-agents
   ```
2. Optionally rename the workspace (e.g., `from-zero-to-agents`).

### Step 4 — Select the API Integration

1. In the **API Integration** dropdown, select:
   ```
   ZERO_TO_AGENTS_GIT_INTEGRATION
   ```

### Step 5 — Select Authentication Method

1. Under authentication, select **Public repository**.
   - Since this is a public GitHub repo, no credentials or tokens are needed.
   - **Note:** This makes the workspace **read-only** — you cannot push changes back to the repo.

### Step 6 — Create the Workspace

1. Click **Create**.
2. Snowflake will clone the repository contents into your workspace.
3. After a few moments, you will see all the lab files in the left-hand file explorer.

### Step 7 — Select a Branch (if needed)

1. In the workspace, click the **Changes** tab at the top of the file explorer.
2. Use the branch dropdown to switch branches if the lab requires a specific branch (e.g., `main`).
3. To get the latest updates at any point, click **Pull**.

### Step 8 — Set Your Execution Context

Before running any SQL or code:

1. In the top-right of the workspace, set your **Role** (e.g., the role assigned by your instructor).
2. Set your **Warehouse** (e.g., `COMPUTE_WH` or the warehouse assigned for the lab).
3. Set your **Database** and **Schema** if required by the lab exercises.

---

## You're Ready!

You now have a read-only workspace with all the lab materials. Open any `.sql` or notebook file from the file explorer and follow the lab instructions.

### Tips

- **Pull updates:** If the instructor pushes changes to the repo during the lab, click the **Changes** tab and select **Pull** to sync.
- **Cannot push:** Since this is a public repo workspace, you cannot commit or push changes back. Your edits stay local to your workspace.
- **Copy files:** If you want to save your work, you can copy files from this workspace into a private workspace using right-click → **Copy to**.

---

## Troubleshooting

| Issue | Solution |
|---|---|
| Don't see the API integration in the dropdown | Ask your instructor to verify the `GRANT USAGE ON INTEGRATION ... TO ROLE PUBLIC` was run, or that your role has USAGE on the integration. |
| "Integration not found" error | Make sure you are selecting `ZERO_TO_AGENTS_GIT_INTEGRATION` (not typing it manually). |
| Workspace creation fails | Ensure the GitHub repo URL is exactly `https://github.com/sfc-gh-sdickson/from-zero-to-agents` with no trailing slash. |
| Files don't appear after creation | Wait a moment and refresh. For large repos, the initial sync may take a few seconds. |
| Need to switch branches | Go to the **Changes** tab → branch dropdown → select the desired branch. Use **Fetch All** if you don't see a recently created branch. |
