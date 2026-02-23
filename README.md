# Deal Flow System Architecture

A robust, deterministic, and scalable real estate wholesaling system that automates lead ingestion from off-market (PropStream) and on-market (Zillow) sources, normalizes them into a canonical Postgres database, underwrites them deterministically, and syncs to a HubSpot CRM for operational follow-ups.

---

## 🏗️ Target Architecture Overview

The system transitions from a monolithic automation script to a decoupled, event-driven architecture using **n8n** as the orchestrator.

### Core Systems
1. **Gmail (Ingestion Queue):** Acts as the frontline router. Incoming property emails are assigned a strict `Source / Deal_Type / State` nested label structure (e.g., `RE/Zillow/Section_8/Alabama`). n8n polls these folders for `Unread` messages, acting as a queuing mechanism.
2. **Postgres (System of Record):** The canonical database storing raw payloads, deduplication keys (`normalized_address_key`), and versioned underwriting assumptions. Provides an auditable trail and allows for batch replays.
3. **n8n (Orchestrator):** Divided into modular sub-workflows (Ingestion, Parsing, Deduplication, Underwriting, HubSpot Sync) for easier error handling and retries.
4. **OpenClaw LLM (Fallback Parser):** A local LLM running on the Windows host, accessed by the n8n WSL container. Used strictly for unstructured data extraction when standard regex fails. **Never used for math.**
5. **HubSpot (Operational CRM):** The human-facing UI. Stores Deals with unique database-level constraints (`deal_key`) to prevent duplicates.

---

## 🔄 System Data Flow

The following diagram illustrates the automated lifecycle of a lead from ingestion to CRM creation.

```mermaid
sequenceDiagram
    participant Source as Zillow/Propstream
    participant Gmail as Gmail (Unread Queue)
    participant n8n_Ingest as n8n (Ingestion & Parsing)
    participant Postgres as Postgres DB
    participant OpenClaw as OpenClaw LLM
    participant n8n_Underwrite as n8n (Underwriting)
    participant HubSpot as HubSpot CRM

    Source->>Gmail: Send Lead Email
    Gmail-->>Gmail: Auto-Label (Source/Deal_Type/State)
    loop Every Minute
        n8n_Ingest->>Gmail: Poll for 'Unread' in Labels
    end
    
    n8n_Ingest->>n8n_Ingest: Try Regex Parsing
    alt Regex Fails
        n8n_Ingest->>OpenClaw: Send HTML (WSL to Host)
        OpenClaw-->>n8n_Ingest: Return Clean JSON (address, price, sqft)
    end
    
    n8n_Ingest->>n8n_Ingest: Generate dedupe slug (123-main-st-tx)
    n8n_Ingest->>Postgres: INSERT ON CONFLICT DO NOTHING (Check Dedupe)
    
    alt Is Duplicate
        Postgres-->>n8n_Ingest: Conflict (Halt Pipeline)
    else Is New Lead
        Postgres-->>n8n_Ingest: Success
        n8n_Ingest->>n8n_Underwrite: Trigger Underwriting
        n8n_Underwrite->>n8n_Underwrite: Calculate MAO, ARV, Rehab (Deterministic)
        n8n_Underwrite->>Postgres: Save Assumptions Snapshot
        n8n_Underwrite->>HubSpot: Create Deal (with unique deal_key)
        HubSpot-->>n8n_Underwrite: Return hs_object_id
        n8n_Underwrite->>Postgres: Update row with Deal ID
        n8n_Underwrite->>Gmail: Mark Thread as 'Read' (Success)
    end
```

---

## 🧑‍💻 Human Interaction & UI Workflow

While n8n handles the data ingestion and math, **HubSpot** is intentionally designed as a streamlined, linear pane of glass for human operators to simply sit down and focus on calling.

```mermaid
stateDiagram-v2
    direction TB
    
    state "HubSpot: Deals Board" as Board
    
    state "Human Operator" as Human {
        state "Filter Deals" as Filter
        state "Call Lead" as Call
        state "Log Call Outcome" as Log
        state "Set Automation Queue" as SetAutomation
    }
    
    state "n8n Automation" as n8n {
        state "Process Follow-up / Drip" as Process
    }
    
    Board --> Filter: Start session (e.g., "Needs Contact")
    Filter --> Call: Open first Deal
    Call --> Log: Record result in Custom Property
    Log --> SetAutomation: Set "Automation Queue" column
    SetAutomation --> Call: Move to next Deal linearly
    
    SetAutomation --> Process: Webhook out to n8n
    
    Call --> Board: End session / Follow-up later
```

### Key Human Touchpoints:
1. **Linear Calling:** The operator filters the Deals table/board based on daily requirements (e.g., "New Deals in Texas"). From there, they simply move down the list, calling leads one by one.
2. **Outcome Logging:** After a call, the human updates the `Call Outcome` column/property (e.g., Left VM, No Answer, Connected).
3. **Triggering the Automation Queue:** The human updates the `Automation Queue` column for that Deal. This keeps them from manually clicking through complex HubSpot stages. Instead, changing this single dropdown fires a webhook to n8n.
4. **n8n Hand-off:** n8n catches the webhook, reads the `Call Outcome`, and automatically executes the appropriate downstream logic (sending an email, creating an SMS drip, or moving the Deal stage in the background).
5. **Dealing with Low Confidence Extraction:** If the automated ingestion failed to pull a price, the Zillow link remains the paramount source of truth. The human clicks the link, enters the price, and continues.

---

## 📂 Project Structure

```text
deal_flow/
├── n8n/                     # Orchestration logic
│   ├── workflows/           
│   │   ├── ingestion/       # A) Gmail polling, B) Parsing, C) Dedupe Gate
│   │   ├── underwrite/      # D) Webhook-triggered Underwriting compute
│   │   └── automation/      # E) HubSpot syncs, F) DLQ/Error Handling
│   └── scripts/             # JS snippets for strict deterministic math
├── hubspot/                 # CRM Definitions
│   ├── properties/          # Custom property schemas (deal_key, estimated_arv)
│   └── pipelines/           # State machine definitions
├── docs/                    
│   ├── user_stories/        # Implementation Roadmap (Phases 1-3)
│   └── system_design.md     # Expanded architecture notes
└── docker-compose.yml       # Local Postgres & n8n environment
```

## 🚀 Implementation Roadmap (See User Stories)
- **Phase 1:** Gmail Taxonomy (`Read/Unread` rules) & HubSpot Deal Key Deduplication.
- **Phase 2:** Canonical Postgres DB, Modular n8n Workflows, and Webhook-based Underwriting.
- **Phase 3:** WSL-to-Host networking for local OpenClaw LLM extraction fallbacks.
