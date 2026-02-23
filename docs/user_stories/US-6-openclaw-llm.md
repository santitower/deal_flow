---
name: Feature request
about: Suggest an idea for this project
title: '[Phase 3] OpenClaw LLM Parsing via WSL-to-Host Networking'
labels: enhancement, phase-3
assignees: ''

---

**Is your feature request related to a problem? Please describe.**
Regex parsing of Zillow emails is incredibly fragile because the HTML DOM changes frequently. We need a fallback when Regex fails to find the list price or address.

**Describe the solution you'd like**
Integrate OpenClaw (running locally on Windows) as a fallback parser in n8n (running in Docker via WSL).

1. **Networking Route:**
   - Ensure n8n nodes are configured to hit the OpenClaw API endpoint by routing from the WSL Docker container to the Windows host using `http://host.docker.internal:<PORT>` or the host's LAN IP.
2. **LLM Node Fallback:**
   - If Regex fails to yield `price` or `address`, route the raw text/HTML to OpenClaw.
   - Use a strict JSON Schema instruction prompt requiring only `{ "address": string, "price": number, "sqft": number, "beds": number }`. NO MATH inside the prompt.
3. **Human Review Gate:**
   - If OpenClaw extraction fails or if the confidence is low/missing fields, mark the deal in HubSpot mapped to a "Needs-Review" stage and apply a specific label in Gmail.

**Describe alternatives you've considered**
Using OpenAI or Anthropic directly, but sticking to local models (OpenClaw) ensures privacy and saves API costs during high-volume ingestion.

**Acceptance Criteria**
- [ ] n8n code can successfully ping OpenClaw using WSL `host.docker.internal` networking.
- [ ] If Regex parser outputs null, OpenClaw captures the HTML and returns the clean JSON payload.
- [ ] Failed/incomplete LLM parsing correctly routes to a Human Review state instead of throwing silent errors.

