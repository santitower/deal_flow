---
name: Feature request
about: Suggest an idea for this project
title: '[Phase 1] Implement Gmail Label Taxonomy & Error Handling'
labels: enhancement, phase-1
assignees: ''

---

**Is your feature request related to a problem? Please describe.**
Right now, the n8n pipeline can blindly fetch Zillow emails repeatedly if polling fails, and duplicates are created. Furthermore, if the ingestion fails, we lose the lead silently because there's no failure routing.

**Describe the solution you'd like**
Implement a strict, state-machine Gmail label schema to ensure emails aren't processed twice and failures are visible.

1. **New Labels Needed (Routing & Categorization):**
   - **Source > Deal Type > State** (Applied by incoming Gmail filter based on 'Subject' or 'Search Name'):
     - `RE/Zillow/Section_8/Alabama`
     - `RE/Zillow/Section_8/Michigan`
     - `RE/Zillow/Section_8/Ohio`
     - `RE/Zillow/Fix_Flip/Arizona` (and FL, GA, NV, NC, TN, TX)
     - `RE/Zillow/Creative/Alabama` (and AZ, FL, GA, IN, MI, NC, OH, TN, TX)
     - *(Same structure applies for `RE/Propstream/` when integrated)*
   *Note on granularity:* City-level or specific buy box labels (e.g., `.../Creative/Texas/Austin_Multifamily`) are **only necessary** if you need to route to differently assigned sales reps immediately or apply vastly different baseline underwriting formulas *before* parsing. Otherwise, n8n will extract the exact City and Address from the email body anyway, so State-level labels keep Gmail cleaner while still organizing your inbox effectively.

2. **Pipeline Status (Read / Unread State Machine):**
   - The trigger will only look for `Unread` emails residing within any of the nested folders above.
   - Once successfully processed by n8n, the email will be marked as `Read`.
   - Optional: If an error occurs, it can remain `Unread` or be tagged with a special `4-Failed` label/starred for manual review.

3. **Workflow Changes:**
   - Update `n8n/workflows/ingestion/zillow_ingest.json`.
   - Ensure the trigger watches for `Unread` messages in the relevant Labels.
   - The workflow reads the `Source` and `Deal_Type` labels applied to map to a specific "Deal Pipeline" or custom property in HubSpot.
   - Add an n8n node at the end of successful HubSpot syncs to mark the Gmail thread/message as `Read`.
   - Create a global "Error Trigger" workflow in n8n that catches failures and ensures the message is flagged for review (e.g.,labeled `Failed`).

**Describe alternatives you've considered**
Using purely strict state-machine labels (New, Processing, Success). Using Read/Unread is simpler to manage natively in Gmail but risks human interference if a user manually clicks an email on their phone before n8n polls it.

**Acceptance Criteria**
- [ ] G-suite labels are created structurally (`Source/Deal_Type/State`).
- [ ] n8n trigger polls for `Unread` messages across those labels.
- [ ] Successful HubSpot sync marks the Gmail message as `Read`.
- [ ] Any pipeline failure triggers the Error workflow to flag the email for human review.

