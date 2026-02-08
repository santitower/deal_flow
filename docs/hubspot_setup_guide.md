# HubSpot Configuration Guide for Deal Flow Project

To ensure your **n8n automations** integrate cleanly with HubSpot, please follow this step-by-step configuration guide. 

> **Important**: When creating properties, pay special attention to the **Internal Name**. You can usually edit this by clicking the `</>` icon next to the name field before saving. The internal names *must* match exactly for the code to work without modification.

---

## 1. Property Groups
First, create these groups to keep your custom data organized.
*   **Settings > Properties > Groups** tab
*   Create a group for **Contacts**: `Wholesale Contact Info`
*   Create a group for **Deals**: `Wholesale Deal Data`

---

## 2. Custom Contact Properties
Go to **Settings > Properties > Contacts** tab. Create the following properties:

| Label | Internal Name | Group | Field Type |
| :--- | :--- | :--- | :--- |
| **Contact Role** | `contact_role` | Wholesale Contact Info | **Dropdown select** <br>Options:<br>- Owner (`owner`)<br>- Listing Agent (`listing_agent`)<br>- Wholesaler (`wholesaler`)<br>- Property Manager (`property_manager`) |
| **Brokerage Name** | `brokerage_name` | Wholesale Contact Info | Single-line text |

---

## 3. Custom Deal Properties
Go to **Settings > Properties > Deals** tab. Create the following properties:

### Core Identification
| Label | Internal Name | Group | Field Type | Note |
| :--- | :--- | :--- | :--- | :--- |
| **Deal Key** | `deal_key` | Wholesale Deal Data | Single-line text | **Unique ID** (Address + Zip). Crucial for deduplication. |
| **Source System** | `source_system` | Wholesale Deal Data | **Dropdown select**<br>Options:<br>- PropStream (`PropStream`)<br>- Zillow (`Zillow`) | |

### Property Data
| Label | Internal Name | Group | Field Type |
| :--- | :--- | :--- | :--- |
| **Estimated ARV** | `estimated_arv` | Wholesale Deal Data | Number (Currency) |
| **MAO** | `mao` | Wholesale Deal Data | Number (Currency) |
| **Equity Amount** | `equity_amt` | Wholesale Deal Data | Number (Currency) |
| **Zestimate** | `zestimate` | Wholesale Deal Data | Number (Currency) |
| **Property Type** | `property_type` | Wholesale Deal Data | Single-line text |
| **Beds** | `beds` | Wholesale Deal Data | Number |
| **Baths** | `baths` | Wholesale Deal Data | Number |
| **SqFt** | `sqft` | Wholesale Deal Data | Number |
| **Year Built** | `year_built` | Wholesale Deal Data | Number |

### Outcomes & Status
| Label | Internal Name | Group | Field Type |
| :--- | :--- | :--- | :--- |
| **Call Outcome** | `call_outcome` | Wholesale Deal Data | **Dropdown select**<br>Options:<br>- No Answer (`no_answer`)<br>- Left VM (`left_vm`)<br>- Connected (`connected`)<br>- Wrong Number (`wrong_number`)<br>- Do Not Contact (`dnc`) |

---

## 4. Deal Pipeline & Stages
Go to **Settings > Objects > Deals > Pipelines** tab.
1.  Create a new pipeline named: **Wholesale Pipeline**
2.  Configure the stages as follows.
    *   *Note: While you can name the stages whatever you like, the automation logic uses specific "Internal IDs" (e.g. `attempted___no_connect`). It is difficult to force these IDs in the UI. Instead, create the stages below, then we will update the n8n workflow to match your specific Pipeline ID and Stage IDs.*

Recommended Stages:
1.  **New Lead** (Probability: 10%)
2.  **Attempted - No Connect** (Probability: 10%)
3.  **Connected - Working** (Probability: 30%)
4.  **Offer Made** (Probability: 50%)
5.  **Under Contract** (Probability: 80%)
6.  **Closed Won** (Probability: 100%)
7.  **Closed Lost** (Probability: 0%)

---

## 5. API Key / Private App
To allow n8n to talk to HubSpot:
1.  Go to **Settings > Integrations > Private Apps**.
2.  Click **Create a private app**.
3.  Name it: **n8n Integration**.
4.  Click **Scopes** and select:
    *   `crm.objects.contacts.read` & `write`
    *   `crm.objects.deals.read` & `write`
    *   `crm.schemas.custom.read` (to read property definitions)
5.  Click **Create app**.
6.  **Copy the Access Token**. You will need this to configure the Credentials in n8n.
