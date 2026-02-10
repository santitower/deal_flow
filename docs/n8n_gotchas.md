# n8n Workflow Development: Gotchas, Assumptions, and Best Practices

This document serves as a living guide for the team to log incorrect assumptions, unexpected behaviors, and version-specific issues encountered during n8n workflow development. By documenting these "hard-won" lessons, we prevent repeating mistakes and accelerate troubleshooting for integrations with HubSpot and other external APIs.

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

## ⚠️ Gotchas

### Node & Versioning Issues

**Symptom:** The HubSpot node fails with a "Bad Request" error or missing fields, even though the configuration looks correct.
**Incorrect Assumption:** The default HubSpot node version in n8n is always the latest and most stable.
**The Reality / Correct Approach:** Nodes often have internal versions (e.g., Version 1 vs. Version 2). Version 1 might use older API endpoints or legacy property formats. The fix is to click the "Update" or "Select Version" button in the node properties to use the modern version compatible with Private App Tokens and Custom Properties.
**Prevention Rule:** Always verify you are using the latest stable node version when adding or troubleshooting API integrations.

---

**Symptom:** Creating a HubSpot Task fails with `At least one metadata field needs to set` or nodes appear empty in the UI.
**Incorrect Assumption:** n8n will automatically associate a task based on context, or the fields should be top-level.
**The Reality / Correct Approach:** In version 2.2.3, HubSpot Engagement nodes require a `metadata` object where fields like `body`, `subject`, and `status` are nested. Crucially, the **"For Object Type"** (internal key `forObjectType`) must be explicitly set to **"Contact"** (capitalized) for tasks to link correctly and for the node to validate. 
**Prevention Rule:** When using HubSpot Engagement nodes, always ensure the `metadata` section is populated and the `forObjectType` matches the case-sensitive dropdown value (e.g., `Contact`, `Deal`).

---

### API-Specific Behavior (e.g., HubSpot)

**Symptom:** Searching for a deal by a property value (e.g., `Automation Queue` equals `Queue`) returns zero results even when deals exist in the UI.
**Incorrect Assumption:** HubSpot search filters are case-insensitive and use the UI label.
**The Reality / Correct Approach:** The HubSpot API is case-sensitive for internal values. If the property's internal value is `queue`, searching for `Queue` will fail.
**Prevention Rule:** Always use the **Internal Value** (lowercase) rather than the UI Label in Search filters and Updates.

---

### Data Mapping & Expressions

**Symptom:** In a workflow that branches and then merges (e.g., creating a Task and then updating the Deal), the final node updates the *wrong* deal or uses the *wrong* item's data.
**Incorrect Assumption:** n8n will automatically "remember" which item in the final node matches which item in a node 3 steps back if using `$node["Name"]`.
**The Reality / Correct Approach:** When a node (like a Task Creator) outputs a new object, the original data stream is broken. To reach back to an earlier node بينما maintaining item synchronization, you must use the syntax **`$('Node Name').item.json.property`**. The `$node["Name"]` syntax is legacy and often returns `undefined` when trying to access `.item`.
**Prevention Rule:** Always use `$('Node Name').item.json` when referencing properties from nodes that are not the immediate parent in a multi-item flow.

---

### Authentication & Credentials

**Symptom:** Importing a workflow JSON results in nodes showing "No Credentials Selected."
**Incorrect Assumption:** Credentials are saved inside the `.json` file of the workflow.
**The Reality / Correct Approach:** Workflow JSON files only store a **Reference ID** and **Name** for credentials. If the target n8n instance doesn't have a credential with that exact ID/Name in its secure database, the mapping will break.
**Prevention Rule:** Maintain a mapping of standard Credential Names (e.g., `HubSpot App Token account`) across instances to ensure smooth imports.

---

### Workflow Logic & Execution

**Symptom:** A Code node receives 4 items from a HubSpot Search node but only returns 1 result.
**Incorrect Assumption:** A simple script like `return { json: { ... } };` will automatically loop for all input items.
**The Reality / Correct Approach:** Top-level `return` statements in Code nodes (especially JS) will stop execution after the first item if not written as a loop. To process every item, you must use `$input.all().map(...)`.
**Prevention Rule:** Use the "Run Once for All Items" mode or explicitly use `.map()` in your Code node to ensure data isn't lost during processing.

---

**Symptom:** The Switch node throws an error: `The output 4 is not allowed. It has to be between 0 and 3!`.
**Incorrect Assumption:** The "Fallback Output" number refers to a default value rather than an output port index.
**The Reality / Correct Approach:** Port indexes are 0-based. If you have 4 outputs (0, 1, 2, 3), selecting 4 for the Fallback will crash the node because output port 4 doesn't exist.
**Prevention Rule:** Ensure your fallback output index is always within the range of existing branch ports.

---

**Symptom:** The Switch node UI restricts the number of output ports, or throws errors when trying to add more than 4 branches.
**Incorrect Assumption:** The standard Switch node can handle an unlimited number of cases via the UI.
**The Reality / Correct Approach:** The default n8n Switch node (v1) is often limited to 4 outputs (0-3). For complex routing with 5+ outcomes, you must either:
1.  Use a **Code Node** to perform the logic and return a branch index.
2.  Use a **Community Node** (like "Dynamic Switch").
3.  **Chain** multiple Switch nodes together.
**Prevention Rule:** Plan for chaining or use a Code node if your logic exceeds 4 discrete branches.

---

**Symptom:** You want to avoid hitting the 1,000-contact limit on HubSpot Free while still using automated tasks for leads you haven't spoken to yet. 
**Incorrect Assumption:** Every Task must be associated with a unique Contact record for the lead.
**The Reality / Correct Approach:** Use an **"Anchor Contact"** (one permanent category placeholder) as the primary object for the Task node. Then, use the `associationsUi` to link the Task to the **Deal ID**. To reference the specific lead data, inject the `property_link` and `due_date` directly into the Task's **Body** field. 
**Prevention Rule:** For bulk processing of properties, anchor tasks to one internal contact and link to the Deal; only create real Contact records once a lead becomes "Warm" or "Hot".

---

**Symptom:** HubSpot Update node fails with `INVALID_LONG` for a Date field (e.g., `2026-02-09T... was not a valid long`).
**Incorrect Assumption:** HubSpot "Date" properties accept ISO strings or JavaScript Date objects.
**The Reality / Correct Approach:** HubSpot's **Date** field (internal type `date`) is strictly a Unix timestamp in **milliseconds** representing **Midnight UTC** of that day. If you send an ISO string or a timestamp with a "time" component, the API will reject it. 
**Prevention Rule:** Use `new Date(Date.UTC(y, m, d)).getTime()` in your code node to generate a clean "Midnight UTC" timestamp for all date properties.


---

**Symptom:** HubSpot node fails with `Unable to parse value for path parameter: dealId`.
**Incorrect Assumption:** The expression `{{ $('Node').item.json.id }}` is automatically cleaned of whitespace by n8n.
**The Reality / Correct Approach:** If there is a single **leading space** or **leading equals sign** inside the text box but *outside* the `{{ }}` brackets, n8n evaluates the ID (e.g., `290575917789`) but then adds the character (e.g., ` 290575917789`). HubSpot's API cannot parse this as a valid numeric ID in the URL path.
**Prevention Rule:** Always click into the field, press `Ctrl+A`, and `Backspace` to ensure the box is truly empty before pasting an expression. Ensure no `=` character exists outside the green highlight.

---

### HubSpot Search Node Properties Bug
**Symptom:** Custom properties (like `call_outcome`) are missing from the node's output, even though they are listed in the "Properties" parameter. Only standard properties (like `dealname`) are returned.
**Incorrect Assumption:** The "Properties" list in the HubSpot (v2) Search node always dictates which fields are returned.
**The Reality / Correct Approach:** In some n8n versions, the Search node ignores the custom property list if "Simple" mode is on or if internal IDs are not refreshed.
**Prevention Rule:** If custom properties are missing, replace the HubSpot node with an **HTTP Request node** using `POST https://api.hubapi.com/crm/v3/objects/deals/search` and explicitly pass the `properties` array in the JSON body.

---

### n8n Expression Syntax (Multiline Logic)
**Symptom:** "Invalid Syntax" or "Expression is invalid" markers in n8n fields even when the JavaScript looks correct.
**Incorrect Assumption:** You can use multiple `if/else` statements and `return` keywords directly in the `{{ ... }}` expression block.
**The Reality / Correct Approach:** n8n expressions are evaluated as a single line. Direct `return` statements will fail. For complex mapping, you must use either:
1.  **A Lookup Object:** `{{ ({'key': 'val', 'key2': 'val2'})[input] || 'fallback' }}`
2.  **An IIFE (Immediately Invoked Function Expression):** `{{ (() => { if(x) return 1; return 0; })() }}`
**Prevention Rule:** Favor lookup objects for simple mappings; use IIFEs for complex logic. Avoid raw multiline JS without a wrapper.

---

### HubSpot Mixed Property Types (Object vs. String)
**Symptom:** Code nodes fail to read custom HubSpot properties or treat them as empty/fallback strings, even when they appear in the UI.
**Incorrect Assumption:** All properties returned by the HubSpot (v2/v3) "Search" or "Get" operation are flat strings when "Simple" mode is on.
**The Reality / Correct Approach:** In some n8n versions/configurations, standard HubSpot properties (like `dealname`) are flattened to strings, but **custom properties** (like `call_outcome`) are returned as objects with a `value` key (e.g., `{ value: "no_answer" }`). String comparisons like `outcome === 'no_answer'` will fail if `outcome` is an object.
**Prevention Rule:** Always use a helper to safely extract the string value: `const getVal = (p) => (p && typeof p === 'object' && p.hasOwnProperty('value')) ? p.value : p;`
