---
name: Feature request
about: Suggest an idea for this project
title: '[Phase 1] Add HubSpot Deduplication Constraints'
labels: enhancement, phase-1
assignees: ''

---

**Is your feature request related to a problem? Please describe.**
n8n is creating duplicate deals in HubSpot when the same property matches multiple Zillow saved searches or if polling repeats.

**Describe the solution you'd like**
HubSpot should prevent the creation of a duplicate deal at the database level by enforcing uniqueness on a custom Deal property.

1. **Deal Key:**
   - Modify the HubSpot schema in `hubspot/properties/deal_properties.json` to require the custom property `deal_key`.
   - Make `deal_key` a **Unique Identifier** in HubSpot deal settings.
2. **n8n Changes:**
   - In n8n, compute the `deal_key` (slugified address like `123-main-st-city-st-zip`).
   - Pass this `deal_key` to the HubSpot deal creation node. If HubSpot rejects with a 409 Conflict, n8n correctly skips creation instead of duplicating, or patches the existing deal.
3. **Zillow URl:**
   - Ensure the `source_listing_url` (Zillow Link) is appended to the Deal, as this is the paramount "source of truth".

**Describe alternatives you've considered**
Searching HubSpot before creating (Search -> Check -> Create). This works, but using a unique ID constraint directly in HubSpot is much faster and more reliable against race conditions.

**Acceptance Criteria**
- [ ] `deal_key` is configured as a Unique Identifier in HubSpot Deal Properties.
- [ ] `zillow_ingest.json` calculates a normalized address slug and sends it as `deal_key`.
- [ ] Duplicate lead simulations cleanly are rejected or updated without making a second Deal.
- [ ] The Zillow link is reliably mapped to the Dealer property `source_listing_url`.

