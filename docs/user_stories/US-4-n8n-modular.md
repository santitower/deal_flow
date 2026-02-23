---
name: Feature request
about: Suggest an idea for this project
title: '[Phase 2] Modularize n8n Ingestion Workflows'
labels: architecture, phase-2
assignees: ''

---

**Is your feature request related to a problem? Please describe.**
The `zillow_ingest.json` workflow is highly monolithic. If parsing fails, the whole workflow fails. If a retry happens, it restarts from the beginning (re-fetching the email).

**Describe the solution you'd like**
Refactor the monolithic n8n pipeline into discrete sub-workflows called via `Execute Workflow` nodes.

1. **A) Ingestion (Gmail polling):**
   - Trigger on `Unread` Gmail in monitored labels, fetch, pass data, call B.
2. **B) Parsing/Normalization:**
   - Takes raw email, extracts data into JSON, generates slug, calls C.
3. **C) Dedupe/Idempotency Gate:**
   - Checks/Inserts to Postgres. If duplicate, skip (or update). If new, call D.
4. **D) Underwriting Compute:**
   - Code node math. Update Postgres, call E.
5. **E) HubSpot Sync:**
   - Create Deal in HubSpot, mark Gmail thread as `Read` via Gmail Node.

**Describe alternatives you've considered**
Keeping them in one workflow but using "Error" outputs on nodes to branch logic. However, isolating them using sub-workflows allows for much cleaner retries and debugging.

**Acceptance Criteria**
- [ ] Workflows A through E are created as distinct n8n workflows.
- [ ] Sub-workflows have clear JSON input/output schemas.
- [ ] The parent ingestion workflow cleanly delegates to sub-workflows instead of containing all nodes itself.

