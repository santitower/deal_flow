# Troubleshooting & Known Pitfalls

This document is a living record of common issues, incorrect assumptions, and "gotchas" encountered during the development and maintenance of the Deal Flow System. Use this as a first stop when encountering unexpected behavior.

---

## 📋 Standard Entry Template

<!-- 
### Category Name
**Symptom:** [Description of the error/behavior]
**Incorrect Assumption:** [The faulty belief]
**The Reality / Correct Approach:** [The true cause and fix]
**Prevention Rule:** [Concise rule of thumb]
-->

---

## ⚠️ Known Pitfalls

### 1. HubSpot n8n Node Version
*   **Issue**: The automation fails with authentication or data handling errors that are difficult to diagnose.
*   **Cause**: The n8n workflow was built using HubSpot node v1, but the required or stable version is HubSpot node v2. The different versions have breaking changes in their API handling and authentication methods.
*   **Solution**: Always verify that the HubSpot node version in the n8n workflow JSON matches the intended version (v2). When importing or creating new workflows, manually check the node version in the editor.

### 2. HubSpot Engagement Metadata (Tasks)
*   **Symptom**: Creating a HubSpot Task fails with `At least one metadata field needs to set` or nodes appear empty in n8n.
*   **Incorrect Assumption**: n8n will automatically associate a task based on context, or the fields should be top-level.
*   **The Reality / Correct Approach**: HubSpot Engagement nodes (v2+) require a `metadata` object where fields like `body`, `subject`, and `status` are nested. Crucially, the **"For Object Type"** (internal key `forObjectType`) must be explicitly set to **"Contact"** or **"Deal"** (case-sensitive) for tasks to validate and link correctly.
*   **Prevention Rule**: Always ensure the `metadata` section is populated and the `forObjectType` matches the case-sensitive dropdown value in the node UI.

### 3. Case Sensitivity in HubSpot Search
*   **Symptom**: Searching for a deal by a property value (e.g., `Automation Queue == "Queue"`) returns zero results even when records exist.
*   **Incorrect Assumption**: HubSpot search filters are case-insensitive or use the UI label.
*   **The Reality / Correct Approach**: The HubSpot API is case-sensitive for internal values. If the property's internal value is `queue`, searching for `Queue` will fail.
*   **Prevention Rule**: Always use the **Internal Value** (lowercase) rather than the UI Label in Search filters and Updates.

### 4. n8n Item Synchronization (The `$('Node Name')` Syntax)
*   **Symptom**: In a workflow that branches and merges, the final node updates the wrong record or uses "undefined" data.
*   **Incorrect Assumption**: n8n automatically "remembers" which item in the final node matches which item in a node several steps back.
*   **The Reality / Correct Approach**: When a node (like a Task Creator) outputs a new object, the original context is lost. To reach back to an earlier node while maintaining item synchronization, you must use the syntax: **`$('Node Name').item.json.property`**. The legacy `$node["Name"]` syntax often fails in modern n8n versions.
*   **Prevention Rule**: Always use `$('Node Name').item.json` when referencing properties from nodes that are not the immediate parent in a multi-item flow.

### 5. HubSpot Date Property Formatting
*   **Symptom**: HubSpot Update node fails with `INVALID_LONG` for a Date field (e.g., `2026-02-09T... was not a valid long`).
*   **Incorrect Assumption**: HubSpot "Date" properties accept ISO strings or JavaScript Date objects.
*   **The Reality / Correct Approach**: HubSpot's **Date** field (internal type `date`) is strictly a Unix timestamp in **milliseconds** representing **Midnight UTC** of that day.
*   **Prevention Rule**: Use `new Date(Date.UTC(y, m, d)).getTime()` in your Code node to generate a clean "Midnight UTC" timestamp.

### 6. HubSpot Search Node - Missing Custom Properties
*   **Symptom**: Custom properties (like `call_outcome`) are missing from the search output, even if explicitly selected.
*   **Incorrect Assumption**: The "Properties" list in the HubSpot Search node always dictates what is returned.
*   **The Reality / Correct Approach**: In some n8n versions, the Search node ignores custom properties if "Simple" mode is on. 
*   **Solution**: If fields are missing, replace the HubSpot node with an **HTTP Request node** using `POST https://api.hubapi.com/crm/v3/objects/deals/search` and explicitly pass the `properties` array in the JSON body.

### 7. n8n Expression Multi-line Syntax
*   **Symptom**: "Invalid Syntax" markers in n8n fields even when the JS look correct.
*   **Incorrect Assumption**: You can use raw `if/else` and `return` statements directly in the `{{ ... }}` expression block.
*   **The Reality / Correct Approach**: n8n expressions must be a single evaluable line.
*   **Solution**: Use a **Lookup Object**: `{{ ({'key': 'val'})[input] || 'fallback' }}` or an **IIFE**: `{{ (() => { return x ? 1 : 0; })() }}`.

---

## 🛠️ Debugging Tips

*   **View JSON Output**: Always toggle the "JSON" view in n8n node results to see the actual property keys being returned (e.g., confirming if a property is a string or an object `{ value: "..." }`).
*   **Workflow Executions Tab**: Check the "Executions" tab in n8n to see exactly what data was passed between nodes in failed runs.
*   **HubSpot Private App Logs**: Check the "Logs" tab inside your HubSpot Private App settings to see the raw API requests and error messages sent by n8n.
