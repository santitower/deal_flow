# System Design Specification

## 1. Core Mental Model

*   **Deal**: The primary unit (Property/Listing). Moves through pipeline stages.
*   **Contact**: The person (Agent/Owner).
*   **Activity**: Calls/Notes logged on Contacts/Deals.

## 2. Ingestion & Normalization

Data flows from sources -> n8n -> HubSpot.
*   **PropStream**: Ingested via CSV/API.
*   **Zillow**: Polled for updates (Snapshot + Delta).
*   **Canonical Schema**: All data is mapped to a standard set of fields (Address, Financials, Contact Info) before entering HubSpot.

## 3. Automation "The Loop"

1.  User logs a **Call Outcome** in HubSpot.
2.  HubSpot/n8n detects the change.
3.  Logic runs based on outcome:
    *   *No Connect* -> Retry count ++, Requeue.
    *   *Connected* -> Move stage, create task.
    *   *Dead* -> Disqualify.

## 4. Pipeline Stages

1.  Uncontacted / New
2.  Queued for Outreach
3.  Attempted – No Connect
4.  Connected – Working
5.  Qualified
6.  Offer/LOI Sent
7.  Negotiation / Counter
8.  Under Contract / Pending
9.  Closed – Won
10. Closed – Lost / Disqualified
