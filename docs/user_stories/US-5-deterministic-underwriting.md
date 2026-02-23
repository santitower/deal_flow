---
name: Feature request
about: Suggest an idea for this project
title: '[Phase 2] Deterministic Underwriting Code Node'
labels: enhancement, phase-2
assignees: ''

---

**Is your feature request related to a problem? Please describe.**
Underwriting math (calculating ARV, rehab, MAO) shouldn't be done via LLMs because LLMs hallucinate numbers and formulas. It must be deterministic.

**Describe the solution you'd like**
Build a standalone, pure Javascript deterministic `Code` node in n8n for underwriting calculations, triggered independent of the main ingestion pipeline.

1. **Standalone Workflow Trigger:**
   - Remove this from the main ingestion sequence (US-4).
   - Create a new n8n workflow triggered via **Webhook**.
   - **HubSpot Automation:** Configure HubSpot to fire a webhook to this n8n workflow whenever a Deal's "Underwriting Status" changes to `Needs Calculation` or when it enters the "Underwriting" pipeline stage. This allows OpenClaw, standard ingestion, or a human user to asynchronously request a fresh calculation.
2. **Parameters & Assumptions:**
   - Define a JSON object for assumptions (e.g., Rehab Costs: Heavy $80, Medium $45, Cosmetic $20; Holding: 6%, Closing: 8%, Investor Profit: 15%, Assignment Fee: $10k).
3. **Logic Check:**
   - Calculate `Rehab` (`sqft * rehab_cost_per_sqft`).
   - Calculate heuristic `ARV` (`List Price * 1.3`). *Note: PropStream API will be integrated here later.*
   - Calculate `MAO` (`ARV - Rehab - Holding - Closing - Profit - Assignment`).
4. **Storage & Sync Back:**
   - Save the exact assumptions dictionary into the `assumptions_snapshot` Postgres JSONB field to ensure auditability.
   - Patch the HubSpot Deal with the newly calculated `MAO`, `ARV`, and `Rehab` values through the HubSpot node.

**Describe alternatives you've considered**
Using a separate microservice for underwriting formulas, but a Javascript node inside n8n is performant enough. Triggering it during the initial ingestion (US-4 step D) was considered, but decoupling it via a HubSpot webhook is far superior because it allows humans to manually request recalculations by just changing a Deal stage.

**Acceptance Criteria**
- [ ] n8n workflow is created with a Webhook trigger.
- [ ] HubSpot Workflow automation fires the webhook when a Deal requires calculation.
- [ ] n8n Code node successfully ingests `list_price` and `sqft` from the webhook payload and calculates MAO deterministically.
- [ ] Assumptions dictionary is stored alongside the calculation results in Postgres.
- [ ] The workflow successfully patches the HubSpot Deal with the finalized numeric results.

