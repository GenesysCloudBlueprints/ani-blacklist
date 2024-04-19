---
title: Blacklisting Phone Numbers
author: yuri.yeti
indextype: blueprint
icon: blueprint
image: images/CallBlacklist.gif
category: 4

summary: |
  This Genesys Cloud Developer Blueprint explains how to set up a trigger to check if an ANI on a voice interaction is blacklisted. If it is blacklisted, the call will be disconnected. This features prevents inbound unwanted or fraudelent calls.
---
This Genesys Cloud Developer Blueprint explains how to set up a trigger to check if an ANI on a voice interaction is blacklisted. If it is blacklisted, the call will be disconnected. This features prevents inbound unwanted or fraudelent calls.
 
When an Architect workflow receives a Communicate call trigger, multiple Genesys Cloud Public API calls are made to assess if a blacklisted number is inbound calling and then terminate the call accordingly.

![Outbound Communicate call Genesys Cloud flow](images/outbound-communicate-call-workflow.png "Genesys Cloud Outbound Communicate Call")

The following illustration shows the end-to-end user experience that this solution enables.

![End-to-end user experience](images/TerminateCallNoQueue.gif "End-to-end user experience")

## Solution components

* **Genesys Cloud** - A suite of Genesys cloud services for enterprise-grade communications, collaboration, and contact center management. Contact center agents use the Genesys Cloud user interface.
* **Genesys Cloud API** - A set of RESTful APIs that enables you to extend and customize your Genesys Cloud environment.
* **Data Table** - Provides the ability to save blacklisted phone numbers from inbound calling.
* **Data Action** - Provides the integration point to invoke a third-party REST web service or AWS lambda.
* **Architect flows** - A flow in Architect, a drag and drop web-based design tool, dictates how Genesys Cloud handles inbound or outbound interactions.
* **Triggers** - Provides the ability for a data action and architect workflow to work cohisively to perform the task.
* **CX as Code** - A Genesys Cloud Terraform provider that provides an interface for declaring core Genesys Cloud objects.

## Prerequisites

### Specialized knowledge

* Administrator-level knowledge of Genesys Cloud
* Expereince with REST API authentication
* Experience with Postman

### Genesys Cloud account

* A Genesys Cloud CX 1 license. For more information, see [Genesys Cloud Pricing](https://www.genesys.com/pricing "Opens the Genesys Cloud pricing article").
* The Master Admin role in Genesys Cloud. For more information, see [Roles and permissions overview](https://help.mypurecloud.com/?p=24360 "Opens the Roles and permissions overview article") in the Genesys Cloud Resource Center.
* CX as Code. For more information, see [CX as Code](https://developer.genesys.cloud/devapps/cx-as-code/ "Goes to the CX as Code page") in the Genesys Cloud Developer Center.

## Configure Genesys Cloud

### Create a custom role to use with Genesys Cloud OAuth clients

1. Navigate to **Admin** > **Roles/Permissions** and click **Add Role**.
2. Type a **Name** for your custom role. (Example: "Blacklist Callers")
3. Search and select the **Architect**>**Datatable**>**All Permissions** permissions
4. Search and select the **Architect**>**Datatable Row**>**All Permissions** permissions
5. Search and select the **Integrations**>**Action**>**All Permissions** permissions
6. Search and select the **OAuth**>**Client**>**All Permissions** permissions
7. Search and select the **processautomation**>**trigger**>**All Permissions** permissions
8. Click **Save** to assign the appropriate permissions to your custom role.
   ![Add a custom role](images/createRole.png "Add a custom role")

## Data Table

### Create a Data Table
1. Go to **Admin**>**Architect**>**Data Table**
2. First you will want to create a data table. Example name can be “Blacklist”. 
2. You will then primarily need to have the Reference Key set as "ani". 
3. Click "Save"
   ![End-to-end user experience](images/TerminateCallNoQueue.gif "End-to-end user experience")

### Add your Blacklist Numbers (to block incoming calls/queues)
1. Open your Data Table
2. Press "+" in the top right corner of the screen. 
3. Under the ani header column, you will store all the phone numbers you wish to block from incoming calls or queues.
4. Click "Save" 
NOTE: The phone numbers need to be formatted using e.164 without the "+", for example; 17705551234. This also allows for CSV import without many formatting issues. More information on this below. 
   ![End-to-end user experience](images/TerminateCallNoQueue.gif "End-to-end user experience")

## Data Action

You will need to create a Genesys Cloud data action that will be used for disconnecting interactions. This can be called “Disconnect interaction”. To set up the data action, make sure you already have an active Genesys Cloud data actions integration setup and follow the steps below or import the action in your ORG.

### Create an OAuth client for use with a Genesys Cloud data action integration

To enable a Genesys Cloud data action to make public API requests on behalf of your Genesys Cloud organization, use an OAuth client to configure authentication with Genesys Cloud.

Create an OAuth client for use with the data action integration with the following custom role.

| Custom role | OAuth Client Name |
|-----------------|-------|
| Blacklist Callers | Disconnect interaction |

To create an OAuth Client in Genesys Cloud:

1. Navigate to **Admin** > **Integrations** > **OAuth** and click **Add Client**.

2. Enter the name for the OAuth client and select **Client Credentials** as the grant type. Click the **Roles** tab and assign the required role for the OAuth client.

3. Click **Save**. Copy the client ID and the client secret values for later use.

   ![End-to-end user experience](images/TerminateCallNoQueue.gif "End-to-end user experience")
   **Note:** Ensure that you copy the client ID and client secret values for each of the OAuth clients.

### Add Genesys Cloud data action integration

Add a Genesys cloud data action integration for each OAuth client being used with this blueprint to call the Genesys Cloud public API to:
* Terminate an inbound blacklisted caller

To create a data action integration in Genesys Cloud:

1. Navigate to **Admin** > **Integrations** > **Integrations** and install the **Genesys Cloud Data Actions** integration. For more information, see [About the data actions integrations](https://help.mypurecloud.com/?p=209478 "Opens the About the data actions integrations article") in the Genesys Cloud Resource Center.

2. Enter a name for the Genesys Cloud data action, such as Update Genesys Cloud User Presence in this blueprint solution.

3. On the **Configuration** tab, click **Credentials** and then click **Configure**.

4. Enter the client ID and client secret that you saved for the Presence Public API [(OAuth Client 1)](#create-oauth-clients-for-use-with-genesys-cloud-data-action-integrations "Goes to the create an OAuth Client section"). Click **OK** and save the data action.

5. Navigate to the Integrations page and set the presence data action integration to **Active**.
   ![Genesys Cloud data actions integration](images/3AGenesysCloudDataActionInstall.png "Genesys Cloud data actions integration")
   ![Rename the data action](images/3BRenameDataAction.png "Rename the data action")
   ![Navigate to the OAuth credentials](images/3CAddOAuthCredentials.png "Navigate to the OAuth credentials")
   ![Add OAuth client credentials](images/3DOAuthClientIDandSecret.png "Add OAuth client credentials")
   ![Set the data integration to active](images/3ESetToActive.png "Set the data action integration to active")
   NOTE: REPLACE ALL THESE SCREENSHOTS WITH GIF

### Import the Genesys Cloud data actions

1. Download the `Disconnect-Interaction.custom.json` JSON file from the [ani-blacklist](https://github.com/GenesysCloudBlueprints/ani-blacklist/exports) GitHub repository.
2. In Genesys Cloud, navigate to **Integrations** > **Actions** and click **Import**.
3. Select the `Disconnect-Interaction.json` file and associate with "Disconnect Interaction" data action integration, which uses the Disconnect Interaction Public API OAuth client.
4. click **Import Action**.

   ![Import the Disconnect Voice Call data action](images/4BImportDisconnectVoiceCallDataAction.png "Import the Update Genesys Cloud User Presence data action")
   ![Import the data action](images/4AImportDataActions.png "Import the data action")
   ![Import the Update Genesys Cloud User Presence data action](images/4BImportPutConversationTagDataAction2.png "Import the Inbound Conversation Details data action")

### Import the Architect workflows

This solution includes one Architect workflow that uses the two [data actions](#add-genesys-cloud-data-action-integrations "Goes to the Add a web services data actions integration section"). This workflow terminates an inbound phone call if it does have have a Queue ID and updates the External Tag on the conversation record to "No Queue".

* The **Blacklist_v5-0.i3WorkFlow** workflow is triggered when a blacklisted caller dials to Genesys Cloud communicate user. This workflow terminates an inbound phone call if it matches the phone number from the Data Table. 

The Event Orchestration trigger invokes these workflows. The workflows in turn calls the Disconnect Voice Call and Put Conversation Tag data actions to update the outbound phone call.

First import this workflow to your Genesys Cloud organization:

1. Download the `Blacklist_v5-0.i3WorkFlow` file from the [ani-blacklist repo](https://github.com/GenesysCloudBlueprints/ani-blacklist) GitHub repository.

2. In Genesys Cloud, navigate to **Admin** > **Architect** > **Flows:Workflow** and click **Add**.

3. Enter a name for the workflow and click **Create Flow**.

4. From the **Save** menu, click **Import**.

5. Select the downloaded **Blacklist_v5-0.i3WorkFlow** file and click **Import**.

6. Review your workflow. Click **Save** and then click **Publish**.
   ![Import the workflow](images/AddWorkflow1.png "Import the workflow")
   ![Name your workflow](images/NameWorkflow1.png "Name your workflow")
   ![Import the workflow](images/ImportWorkflow1.png "Import the workflow")
   ![Import your workflow file](images/SelectWorkflow1ImportFile.png "Import your workflow file")
   ![Save your workflow](images/ImportedWorkflow1.png "Save your workflow")

   :::primary
   **Note:** If you would like to change the External Tag, replace **No Queue** in the **externalTagName** field with the string of your choice.
   :::

   :::primary
   **Note:** If you imported the `Terminate Outbound Call Missing Queue with PSTN Call Leg Check.i3WorkFlow` file, your workflow will look like the screenshot below. 
   :::

   ![Save your workflow](images/ImportedWorkflow2.png "Save your workflow")

   :::primary
   **Note:** If you imported the `Terminate Outbound Call Missing Queue with PSTN Call Leg Check.i3WorkFlow` file, your workflow will look like the screenshot above.
   :::

## Create the event orchestration triggers

Create the trigger that invokes the created Architect workflow.

1. From Admin Home, search for **Triggers** and navigate to the Triggers list.

   ![Navigate to Triggers](images/NavigateToTriggers.png "Navigate to Triggers")

2. From the Triggers list, click **Add Trigger**

   ![Add Trigger](images/AddTrigger.png "Add Trigger")

3. From the Add New Trigger modal, name your trigger and click **Add**

   ![Name Trigger](images/NameTrigger.png "Name Trigger")

4. From the Trigger single view, in the **Topic Name** menu, select **v2.detail.events.conversation.{id}.user.start**.  In the **Workflow Target** menu, select **Terminate Outbound Call Missing Queue**.  Leave **Data Format** as **TopLevelPrimitives**.  Click **Add Condition**.  For more information, see [Available Topics](https://developer.genesys.cloud/notificationsalerts/notifications/available-topics "Opens the Available Topics article") in the Genesys Cloud Developer Center.  Using the notification monitoring tool in the Developer Center, you can watch the notifications happen.

  ![Configure Trigger](images/ConfigureTrigger.png "Configure Trigger")

5. From the Trigger single view, in the **JSON Path** field, type **queueId**.  In the **Operator** menu, select **Exists**.  Set the **Value** toggle to **False**.  Click **Create**.

   ![Configure Trigger Criteria](images/ConfigureTriggerCriteria.png "Configure Trigger Criteria")

   :::primary
   **Note:** If you are interested in allowing PBX calls to other GC users, adding the following criteria to your trigger may allow you to use the simpler `Terminate Outbound Call Missing Queue.i3WorkFlow` file for your Architect workflow. This will reduce the amount of time between the trigger firing and the call being disconnected. You can adjust the string in the contains condition to match your business needs. Especially if your agents are calling specific country codes.
   :::

   ![Additional Trigger Criteria](images/AdditionalTriggerCriteria.png "Additional Trigger Criteria")

6. From the Trigger single view, set the **Active** toggle to **Active**.  Click **Save**.

   ![Activate Trigger](images/ActivateTrigger.png "Activate Trigger")


## Additional resources

* [Genesys Cloud API Explorer](https://developer.genesys.cloud/devapps/api-explorer "Opens the GC API Explorer") in the Genesys Cloud Developer Center
* [Genesys Cloud notification triggers](https://developer.genesys.cloud/notificationsalerts/notifications/available-topics "Opens the Available topics page") in the Genesys Cloud Developer Center
* The [terminate-voice-calls-with-no-queue repo](https://github.com/GenesysCloudBlueprints/terminate-voice-calls-with-no-queue) repository in GitHub
