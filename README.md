# Deal Flow System

A deal-centric real estate wholesaling system that automates lead ingestion, normalization, and operational follow-ups.

## System Overview

This system aggregates leads from **PropStream** (off-market) and **Zillow** (on-market), normalizes them into a canonical **HubSpot Deal** schema, and uses **n8n** to drive automation based on user activities (outcome-based calling).

### Core Components

*   **n8n**: The central nervous system for data ingestion, transformation, and complex automation logic.
*   **HubSpot**: The user interface and database of record. Stores Deals, Contacts, and Companies.
*   **PropStream & Zillow**: Data sources.

## Project Structure

```text
deal-flow-project/
├── n8n/                     # n8n workflows and scripts
│   ├── workflows/           # JSON exports of workflows
│   │   ├── ingestion/       # Data ingestion flows
│   │   ├── transform/       # Normalization logic
│   │   └── automation/      # Outcome handling & follow-ups
│   └── scripts/             # JS snippets for Function nodes
├── hubspot/                 # HubSpot configuration
│   ├── properties/          # Custom property definitions
│   └── pipelines/           # Pipeline stage definitions
├── scripts/                 # Utility scripts
└── docs/                    # Detailed system documentation
```

## Getting Started

1.  **HubSpot Setup**: Apply the configuration in `hubspot/properties` to your HubSpot account.
2.  **n8n Setup**: Import workflows from `n8n/workflows` into your n8n instance.
3.  **Environment Variables**: Configure credentials in `n8n/credentials`.

## Documentation

*   [System Design](docs/system_design.md)
*   [API Reference](docs/api_reference.md)
