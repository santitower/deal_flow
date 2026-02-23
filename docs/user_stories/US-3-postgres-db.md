---
name: Feature request
about: Suggest an idea for this project
title: '[Phase 2] Postgres Database as Canonical Data Store'
labels: enhancement, phase-2
assignees: ''

---

**Is your feature request related to a problem? Please describe.**
Currently, there is no canonical system of record for ingested leads. If a HubSpot sync fails or an underwriting assumption changes, we cannot replay the raw leads because the data is only stored in HubSpot (which lacks the raw payload) and Gmail (which is unstructured).

**Describe the solution you'd like**
Set up a Postgres database instance to store the canonical `property_leads` data model.

1. **Table Schema (`property_leads`):**
   - `id` (UUID, PK)
   - `source_message_id` (String)
   - `normalized_address_key` (String, Unique)
   - `hubspot_deal_id` (String, Nullable)
   - Raw Property Attributes: `raw_address`, `beds`, `baths`, `sqft`, `list_price`, `listing_url`, `zestimate_rent`
   - Computed Fields: `arv_estimated`, `rehab_estimated`, `mao`, `assignment_fee`, `projected_profit`, `cash_on_cash_roi`
   - Audit: `underwriting_version`, `assumptions_snapshot` (JSONB), `ingested_at`, `status`, `last_error`
2. **Postgres Integration in n8n:**
   - Add Postgres credentials to n8n.
   - Build queries in n8n nodes to insert leads using `ON CONFLICT DO NOTHING` for idempotency before doing any heavy processing.

**Describe alternatives you've considered**
Using a Google Sheet or Airtable. However, Postgres is more robust, supports proper JSONB snapshots and unique constraints, and scales better natively with n8n.

**Acceptance Criteria**
- [ ] Local or remote Postgres database is running and accessible.
- [ ] `property_leads` table is created with the exact schema.
- [ ] n8n is connected to Postgres and can successfully insert a test lead.
- [ ] `ON CONFLICT` prevents duplicate `normalized_address_key` insertions.

