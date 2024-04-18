---
title: Terminate outbound voice calls with no queue
author: yuri.yeti
indextype: blueprint
icon: blueprint
image: images/TerminateCallNoQueue.gif
category: 4
summary: |
  This Genesys Cloud Developer Blueprint explains how to set up Genesys Cloud to terminate an outbound voice call with no queue and place an external tag on the call for analytics and follow-up.
---
:::{"alert":"primary","title":"About Genesys Cloud Blueprints","autoCollapse":false} 
Genesys Cloud blueprints were built to help you jump-start building an application or integrating with a third-party partner. 
Blueprints are meant to outline how to build and deploy your solutions, not a production-ready turn-key solution.
 
For more details on Genesys Cloud blueprint support and practices, 
see our Genesys Cloud blueprint [FAQ](https://developer.genesys.cloud/blueprints/faq "Opens the Blueprint FAQ") sheet.
:::

This Genesys Cloud Developer Blueprint explains how to set up Genesys Cloud to terminate an outbound voice call with no queue and place an external tag on the call for analytics and follow-up.

When an Architect workflow receives a Communicate call trigger, multiple Genesys Cloud Public API calls are made to update the conversation with an External Tag and then terminate the call.

:::primary
**Note:** Customers leveraging this blueprint MUST provide an alternate e911 solution for their agents as this blueprint cuts off the agents ability to make an outbound PSTN call without associating a queue to the outbound call.
:::

![Outbound Communicate call Genesys Cloud flow](images/outbound-communicate-call-workflow.png "Genesys Cloud Outbound Communicate Call")

The following illustration shows the end-to-end user experience that this solution enables.

![End-to-end user experience](images/TerminateCallNoQueue.gif "End-to-end user experience")

## Solution components

* **Genesys Cloud** - A suite of Genesys cloud services for enterprise-grade communications, collaboration, and contact center management. Contact center agents use the Genesys Cloud user interface.
* **Genesys Cloud API** - A set of RESTful APIs that enables you to extend and customize your Genesys Cloud environment.
* **Architect flows** - A flow in Architect, a drag and drop web-based design tool, dictates how Genesys Cloud handles inbound or outbound interactions.
* **Data Action** - Provides the integration point to invoke a third-party REST web service or AWS lambda.
* **CX as Code** - A Genesys Cloud Terraform provider that provides an interface for declaring core Genesys Cloud objects.

## Prerequisites

### Specialized knowledge

* Administrator-level knowledge of Genesys Cloud

### Genesys Cloud account

* A Genesys Cloud CX 1 license. For more information, see [Genesys Cloud Pricing](https://www.genesys.com/pricing "Opens the Genesys Cloud pricing article").
* The Master Admin role in Genesys Cloud. For more information, see [Roles and permissions overview](https://help.mypurecloud.com/?p=24360 "Opens the Roles and permissions overview article") in the Genesys Cloud Resource Center.
* CX as Code. For more information, see [CX as Code](https://developer.genesys.cloud/devapps/cx-as-code/ "Goes to the CX as Code page") in the Genesys Cloud Developer Center.

### Development tools running in your local environment

* Terraform (the latest binary). For more information, see [Install Terraform](https://www.terraform.io/downloads.html "Goes to the Install Terraform page") on the Terraform website.

## Implementation steps

You may choose to implement Genesys Cloud objects via the UI or by using Terraform.
* [Configure Genesys Cloud using Terraform](#configure-genesys-cloud-using-terraform)
* [Configure Genesys Cloud manually](#configure-genesys-cloud-manually)

### Download the repository containing the project files

1. Clone the [terminate-voice-calls-with-no-queue repository](https://github.com/GenesysCloudBlueprints/terminate-voice-calls-with-no-queue "Goes to the terminate-voice-calls-with-no-queue repository") in GitHub.

## Configure Genesys Cloud using Terraform

If you want to allow Communicate/PBX calls between GC Users, use the **/terraform-with-pbx** folder; if not, use the **/terraform-without-pbx** folder.

### Set up Genesys Cloud

1. You need to set the following environment variables in a terminal window before you can run this project using the Terraform provider:

 * `GENESYSCLOUD_OAUTHCLIENT_ID` - This variable is the Genesys Cloud client credential grant Id that CX as Code executes against. 
 * `GENESYSCLOUD_OAUTHCLIENT_SECRET` - This variable is the Genesys Cloud client credential secret that CX as Code executes against. 
 * `GENESYSCLOUD_REGION` - This variable is the Genesys Cloud region in your organization.

2. Set the environment variables in the folder where Terraform is running. 

### Configure your Terraform build

Set the following values in the **/terraform-{with/without}-pbx/dev.auto.tfvars** file, specific to your Genesys Cloud organization:

* `client_id` - The value of your OAuth Client ID using Client Credentials to be used for the data action integration.
* `client_secret`- The value of your OAuth Client secret using Client Credentials to be used for the data action integration.

The following is an example of the dev.auto.tfvars file.

```
client_id       = "your-client-id"
client_secret   = "your-client-secret"
```

### Run Terraform

The blueprint solution is now ready for your organization to use. 

1. Change to the **/terraform-with-pbx** or **/terraform-without-pbx** folder and issue the following commands:

* `terraform init` - This command initializes a working directory containing Terraform configuration files.
  
* `terraform plan` - This command executes a trial run against your Genesys Cloud organization and displays a list of all the Genesys Cloud resources created. Review this list and ensure that you are comfortable with the plan before moving on to the next step.

* `terraform apply --auto-approve` - This command creates and deploys the necessary objects in your Genesys Cloud account. The --auto-approve flag completes the required approval step before the command creates the objects.

Once the `terraform apply --auto-approve` command has completed, you should see the output of the entire run along with the number of objects that Terraform successfully created. The following points should be remembered:

* In this project, assume you are running using a local Terraform backing state. In this case, the `tfstate` files are created in the same folder where the project is running. It is not recommended to use local Terraform backing state files unless you are running from a desktop or are comfortable deleting files.

* As long as you keep your local Terraform backing state projects, you can tear down this blueprint solution by changing to the `docs/terraform` folder. You can also issue a `terraform destroy --auto-approve` command. All objects currently managed by the local Terraform backing state are destroyed by this command.

## Configure Genesys Cloud manually

### Create custom roles for use with Genesys Cloud OAuth clients

Create a custom role for use with a Genesys Cloud OAuth client with the following permissions.
:::primary
**Note:** Custom role 2 is only required if you would still like GC users to make Communicate/PBX calls to other GC users.
:::

| Roles           | Permissions | Role Name |
|-----------------|-------------------------|---------|
| Custom role 1 | **Conversation** > **Communication** > **Disconnect**, **Conversation** > **ExternalTag** > **Edit**  | Terminate Conversation Public API |
| Custom role 2 | **Analytics** > **Conversation Detail** > **View** | Get Conversation Details Public API |

To create a custom role in Genesys Cloud:

1. Navigate to **Admin** > **Roles/Permissions** and click **Add Role**.

   ![Add a custom role](images/createRole.png "Add a custom role")

2. Enter the **Name** for your custom role.

   ![Name the custom role](images/nameCustomRole.png "Name the custom role")

3. Search and select the required permission for each of the custom role.
   ![Add permissions to the custom role](images/assignPermissionToCustomRole.png "Add permissions to the custom role")
4. Click **Save** to assign the appropriate permission to your custom role.

   :::primary
   **Note:** Assign this custom role to your user before creating the Genesys Cloud OAuth client.
   :::

### Create an OAuth client for use with a Genesys Cloud data action integration

To enable a Genesys Cloud data action to make public API requests on behalf of your Genesys Cloud organization, use an OAuth client to configure authentication with Genesys Cloud.

Create an OAuth client for use with the data action integration with the following custom roles.
:::primary
**Note:** OAuth Client 2 is only required if you would still like GC users to make Communicate/PBX calls to other GC users.
:::


| OAuth Client   | Custom role | OAuth Client Name |
|----------------|-------------------------------|-------|
| OAuth Client 1 | Terminate Conversation Public API | Terminate Conversation Public API |
| OAuth Client 2 | Get Conversation Details Public API | Get Conversation Details Public API |


To create an OAuth Client in Genesys Cloud:

1. Navigate to **Admin** > **Integrations** > **OAuth** and click **Add Client**.

   ![Add an OAuth client](images/2AAddOAuthClient.png "Add an OAuth client")

2. Enter the name for the OAuth client and select **Client Credentials** as the grant type. Click the **Roles** tab and assign the required role for the OAuth client.

   ![Select the custom role and the grant type](images/2BOAuthClientSetup2.png "Select the custom role and the grant type")

3. Click **Save**. Copy the client ID and the client secret values for later use.

   ![Copy the client ID and client secret values](images/2COAuthClientCredentials2.png "Copy the client ID and client secret values")

   :::primary
   **Note:** Ensure that you copy the client ID and client secret values for each of the OAuth clients.
   :::

### Add Genesys Cloud data action integration

Add a Genesys cloud data action integration for each OAuth client being used with this blueprint to call the Genesys Cloud public API to:
* Terminate an outbound conversation that does not have a Queue ID
* Add an External Tag to conversations terminated due to missing Queue ID
* Optional: Check to see if the outbound call is to another GC user

:::primary
**Note:** The optional 3rd bullet requires a second data action integration be created associated to OAuth Client 2 mentioned earlier in this blueprint.
:::

To create a data action integration in Genesys Cloud:

1. Navigate to **Admin** > **Integrations** > **Integrations** and install the **Genesys Cloud Data Actions** integration. For more information, see [About the data actions integrations](https://help.mypurecloud.com/?p=209478 "Opens the About the data actions integrations article") in the Genesys Cloud Resource Center.

   ![Genesys Cloud data actions integration](images/3AGenesysCloudDataActionInstall.png "Genesys Cloud data actions integration")

2. Enter a name for the Genesys Cloud data action, such as Update Genesys Cloud User Presence in this blueprint solution.

   ![Rename the data action](images/3BRenameDataAction.png "Rename the data action")

3. On the **Configuration** tab, click **Credentials** and then click **Configure**.

   ![Navigate to the OAuth credentials](images/3CAddOAuthCredentials.png "Navigate to the OAuth credentials")

4. Enter the client ID and client secret that you saved for the Presence Public API [(OAuth Client 1)](#create-oauth-clients-for-use-with-genesys-cloud-data-action-integrations "Goes to the create an OAuth Client section"). Click **OK** and save the data action.

   ![Add OAuth client credentials](images/3DOAuthClientIDandSecret.png "Add OAuth client credentials")

5. Navigate to the Integrations page and set the presence data action integration to **Active**.

   ![Set the data integration to active](images/3ESetToActive.png "Set the data action integration to active")

### Import the Genesys Cloud data actions

Import the following JSON files from the [terminate-voice-calls-with-no-queue repo](https://github.com/GenesysCloudBlueprints/terminate-voice-calls-with-no-queue/exports) GitHub repository:
* `Disconnect-Voice-Call.custom.json`
* `Put-Conversation-Tag.custom.json`
* Optional: `Check-Conversation-For-PSTN-Leg.custom.json`

:::primary
**Note:** The optional 3rd data action is required if you would still like GC users to make Communicate PBX calls to one another. This data action checks to see if the conversation has an external call leg to the PSTN.  Repeat Steps 1-3 below with the `Check-Conversation-For-PSTN-Leg.custom.json` data action if you'd like to import this optional data action.  Be sure to associate with the Data Action Integration associated with the `Get Conversation Details Public API OAuth Client 2` mentioned earlier in this blueprint.
:::

Import the `Disconnect-Voice-Call.custom.json` and `Put-Conversation-Tag.custom.json` files and associate with the Terminate Outbound Conversations With No Queue ID data action integration, which uses the Terminate Conversation Public API OAuth client.

1. From the [terminate-voice-calls-with-no-queue repo](https://github.com/GenesysCloudBlueprints/terminate-voice-calls-with-no-queue/exports) GitHub repository, download the `Disconnect-Voice-Call.custom.json` file.

2. In Genesys Cloud, navigate to **Integrations** > **Actions** and click **Import**.

   ![Import the data action](images/4AImportDataActions.png "Import the data action")

3. Select the `Disconnect-Voice-Call.custom.json` file and associate with the [Terminate Outbound Conversations With No Queue ID](#add-genesys-cloud-data-action-integrations "Goes to the Add Genesys Cloud data action integrations section") integration, and then click **Import Action**.

   ![Import the Disconnect Voice Call data action](images/4BImportDisconnectVoiceCallDataAction.png "Import the Update Genesys Cloud User Presence data action")


4. From the [terminate-voice-calls-with-no-queue repo](https://github.com/GenesysCloudBlueprints/terminate-voice-calls-with-no-queue/exports) GitHub repository, download the `Put-Conversation-Tag.custom.json` file.

5. In Genesys Cloud, navigate to **Integrations** > **Actions** and click **Import**.

   ![Import the data action](images/4AImportDataActions.png "Import the data action")

6. Select the `Put-Conversation-Tag.custom.json`file and associate it with the [Terminate Outbound Conversations With No Queue ID](#add-genesys-cloud-data-action-integrations "Goes to the Add Genesys Cloud data action integrations section") integration, and then click **Import Action**.

   ![Import the Update Genesys Cloud User Presence data action](images/4BImportPutConversationTagDataAction2.png "Import the Inbound Conversation Details data action")

### Import the Architect workflows

This solution includes one Architect workflow that uses the two [data actions](#add-genesys-cloud-data-action-integrations "Goes to the Add a web services data actions integration section"). This workflow terminates an outbound phone call if it does have have a Queue ID and updates the External Tag on the conversation record to "No Queue".

* The **Terminate Outbound Call Missing Queue.i3WorkFlow** workflow is triggered when a Genesys Cloud user makes a Communicate call. This workflow terminates an outbound phone call if it does have have a Queue ID and updates the External Tag on the conversation record to "No Queue".

The Event Orchestration trigger invokes these workflows. The workflows in turn calls the Disconnect Voice Call and Put Conversation Tag data actions to update the outbound phone call.

First import this workflow to your Genesys Cloud organization:

1. Download the `Terminate Outbound Call Missing Queue.i3WorkFlow` file from the [terminate-voice-calls-with-no-queue repo](https://github.com/GenesysCloudBlueprints/terminate-voice-calls-with-no-queue/exports) GitHub repository.

   :::primary
   **Note:** If you would like to still allow Communicate/PBX calls between GC Users, use the `Terminate Outbound Call Missing Queue with PSTN Call Leg Check.i3WorkFlow` file.
   :::

2. In Genesys Cloud, navigate to **Admin** > **Architect** > **Flows:Workflow** and click **Add**.

   ![Import the workflow](images/AddWorkflow1.png "Import the workflow")

3. Enter a name for the workflow and click **Create Flow**.

   ![Name your workflow](images/NameWorkflow1.png "Name your workflow")

4. From the **Save** menu, click **Import**.

   ![Import the workflow](images/ImportWorkflow1.png "Import the workflow")

5. Select the downloaded **Terminate Outbound Call Missing Queue.i3WorkFlow** file and click **Import**.

   ![Import your workflow file](images/SelectWorkflow1ImportFile.png "Import your workflow file")

6. Review your workflow. Click **Save** and then click **Publish**.

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
