# HubSpot Post-Call Follow-Up Automation (n8n)

This document provides a detailed explanation of the n8n automation workflow designed to handle post-call activities within the HubSpot Leads Pipeline. By utilizing custom properties for queuing and status tracking, this system ensures every lead is followed up on consistently without manual overhead.

---

### 1. Trigger and Schedule (Localhost Support)
Since the system is running on **localhost**, a traditional real-time Webhook is not used. Instead, the workflow uses a **Polling Trigger**:
*   **Schedule Trigger**: The workflow is set to run automatically at a specific interval (e.g., every 1 minute).
*   **HubSpot Search**: On every run, n8n proactively asks HubSpot: "Are there any deals where the `Automation Queue` is set to `Queue`?"
*   **Impact**: This allows the automation to work perfectly inside a local or firewalled environment without needing a public URL (Ngrok/Cloudflare).

### 2. Deal Identification
The workflow uses the `Automation Queue` property as a traffic controller. 
*   **Selection**: It only pulls records where `Automation Queue == "Queue"`.
*   **Purpose**: This prevents the automation from running on every single record in your CRM. It only activates when a human (or another system) explicitly requests processing by setting the status to "Queue".

### 3. Data Retrieval
For every identified deal, the workflow gathers a specific payload of information to determine the next steps:
*   **Call Outcome**: The core driver of the logic (e.g., No Answer, Warm, Hot).
*   **Follow-Up Date**: The manual override field. If this contains a date, n8n will prioritize it over the default logic.
*   **Call Notes**: The most recent engagement notes are often retrieved to be included in follow-up tasks or messages.
*   **Contact Info**: Email and Phone details are retrieved for communication actions.

### 4. Conditional Logic (The Router)
The heart of the workflow is a **Switch** or **Router** node that evaluates the `Call Outcome` property. The automation "branches" into different paths:
*   **No Answer / Left VM**: Routes to a "Nurture" path (e.g., send a "Sorry I missed you" SMS and schedule a callback for 2 days later).
*   **Warm**: Routes to a "Working" path (e.g., move deal stage to "Warm", create a task for a detailed property analysis).
*   **Hot**: Routes to an "Urgent" path (e.g., notify the manager via Slack, move deal to "Hot", and block out time for an offer call).
*   **DNC / Wrong Number**: Routes to a "Cleanup" path (e.g., Opt-out the contact and move the deal to "Closed Lost").

### 5. Automated Actions
Once the path is determined, n8n executes a sequence of actions:
*   **Task Creation**: Automatically assigns follow-up tasks to the owner (e.g., "Send Purchase Agreement").
*   **Deal Stage Movement**: Shifts the lead across the board (e.g., from "Uncontacted" to "Pending Contract").
*   **Messaging**: Sends templated emails or SMS messages through integrated providers.
*   **Property Updates**: Logs internal metadata, such as the `Last Automation Run` timestamp.

### 6. Status Update & Prevention of Re-processing
To ensure efficiency and prevent "infinite loops," the final step of *every* branch is to update the record in HubSpot:
*   **Processed**: The `Automation Queue` is set to `Processed`.
*   **Needs Review**: If the logic encounters an error (e.g., a missing email address), it sets the status to `Needs Review` to alert a human.
*   **Impact**: On the next run, n8n will ignore this record because it is no longer in the "Queue" state.

### 7. Overall Benefits
*   **Zero Lead Leakage**: No "Warm" lead is forgotten because a task is created instantly.
*   **Consistency**: Every "No Answer" gets the exact same high-quality SMS follow-up, regardless of how busy the agent is.
*   **Scalability**: One agent can handle hundreds of calls per day because the "admin work" of moving stages and scheduling tasks is handled by n8n.

### 8. After-Call Workflow Steps (For Users)
For the automation to work correctly, the sales rep or user must log the call properly in HubSpot once the call ends. The typical after-call workflow is:

1.  **Select the Call Outcome**: Choose the appropriate outcome from the dropdown (e.g., No Answer, Not Interested, etc.) that reflects how the call went.
2.  **Add Call Notes (Optional)**: If there were important details from the conversation, enter those into the call notes section. These are read by the automation workflow for context.
3.  **Set a Follow-Up Date (Optional)**: If you have a specific date in mind (e.g., a requested appointment), set the `Follow-Up Date` field. This acts as an override.
4.  **Mark for Automation**: Finally, update the **Automation Queue** field to **"Queue"**. This is the trigger for the n8n workflow to pick up the deal.

> [!WARNING]
> Skipping any of these steps (especially forgetting to set the status to "Queue") will result in the automation failing to trigger.

---

### 9. Calling Workflow Notes (Practical Setup)
In practice, the calling workflow involves a combination of phone usage and tracking information on the computer:

*   **Calling Method**: Sales calls are typically made using **Google Voice** on a phone. This allows the caller to use a business number and have the flexibility of a mobile phone.
*   **HubSpot Call List**: While on the call, the computer displays the HubSpot call list or contact record. This provides the contact details, quick links, and active fields (`Call Outcome`, `Automation Queue`) for real-time updates.
*   **Second Screen Reference**: If available, a second monitor should be used to show the property listing or relevant research. This allows the caller to quickly reference specifics without putting the call on hold.

Using this two-screen setup helps streamline the process. Once the call ends and you set the Automation Queue to "Queue", n8n will handle the next steps automatically.
