---
title: "Update the presence of a Genesys Cloud user based upon the answer of a Communicate call"
author: yuri.yeti
indextype: blueprint
icon: blueprint
image: images/OpenScriptDropdown.png
category: 6
summary: |
  This Genesys Cloud Developer Blueprint explains how to set up Genesys Cloud to update a Genesys Cloud user's presence upon the answer of a Communicate (non-ACD or PBX) call.
---

This Genesys Cloud Developer Blueprint explains how to set up Genesys Cloud to update a Genesys Cloud user's presence when the user answers an inbound GC Communicate (non-ACD or PBX) call.

When an Architect workflow receives a communicate call trigger, a Genesys Cloud Public API call is made to update the presence of the Genesys Cloud users on the Communicate call when someone answers the Communicate Call.

![Inbound Communicate Call Genesys Cloud user presence flow](images/inbound-communicate-call-gc-presence-workflow.png "Genesys Cloud presence update from an inbound Communicate call")

![Outbound Communicate Call Genesys Cloud user presence flow](images/outbound-communicate-call-gc-presence-workflow.png "Genesys Cloud presence update from an outbound Communicate call")

The following shows the end-to-end user experience that this solution enables.

![End-to-end user experience](images/GCPresenceUpdateonCommunicateCall.gif "End-to-end user experience")

## Solution components

* **Genesys Cloud** - A suite of Genesys cloud services for enterprise-grade communications, collaboration, and contact center management. Contact center agents use the Genesys Cloud user interface.
* **Genesys Cloud API** - A set of RESTful APIs that enables you to extend and customize your Genesys Cloud environment.
* **Postman** - A platform for creating and sharing APIs.

## Prerequisites

### Specialized knowledge

* Administrator-level knowledge of Genesys Cloud
* Experience with REST API authentication
* Experience with Postman

### Genesys Cloud account

* A Genesys Cloud 1 license. For more information, see [Genesys Cloud Pricing](https://www.genesys.com/pricing "Opens the pricing article").
* The Master Admin role in Genesys Cloud. For more information, see [Roles and permissions overview](https://help.mypurecloud.com/?p=24360 "Opens the Roles and permissions overview article") in the Genesys Cloud Resource Center.

## Configure Genesys Cloud

### Create three custom roles for use with Genesys Cloud OAuth clients

1. Navigate to **Admin** > **Roles/Permissions** and click **Add Role**.

   ![Add a custom role](images/createRole.png "Add a custom role")

2. Type a **Name** for your custom role.

  ![Name the custom role](images/nameCustomRole.png "Name the custom role")

3. Search and select the **processautomation**>**trigger**>**All Permissions** permissions and click **Save** to assign the appropriate permissions to your custom role.

:::primary
**Note:** Assign this role to your user record before creating the Genesys Cloud OAuth client, as described in the next section.  The **processautomation**>**trigger**>**All Permissions** permissions require event orchestration to be activated in your Genesys Cloud organization.
:::

![Add permissions to the custom role](images/assignPermissionToCustomRole.png "Add permissions to the custom role")

4. Navigate to **Admin** > **Roles/Permissions** and click **Add Role**.

   ![Add a custom role](images/createRole.png "Add a custom role")

5. Type a **Name** for your custom role.

  ![Name the custom role](images/nameCustomRole2.png "Name the custom role")

6. Search and select the **presence**>**All Permissions** permissions and click **Save** to assign the appropriate permissions to your custom role.

:::primary
**Note:** Assign this role to your user record before creating the Genesys Cloud OAuth client, as described in the next section.
:::

![Add permissions to the custom role](images/assignPermissionToCustomRole2.png "Add permissions to the custom role")

7. Navigate to **Admin** > **Roles/Permissions** and click **Add Role**.

   ![Add a custom role](images/createRole.png "Add a custom role")

8. Type a **Name** for your custom role.

  ![Name the custom role](images/nameCustomRole3.png "Name the custom role")

9. Search and select the **Analytics**>**Conversation Detail**>**View** permission and click **Save** to assign the appropriate permissions to your custom role.

:::primary
**Note:** Assign this role to your user record before creating the Genesys Cloud OAuth client, as described in the next section.
:::

![Add permissions to the custom role](images/assignPermissionToCustomRole3.png "Add permissions to the custom role")

### Create two OAuth clients for use with Genesys Cloud data action integrations

To enable a Genesys Cloud data action to make public API requests on behalf of your Genesys Cloud organization, use an OAuth client to configure authentication with Genesys Cloud.

1. Navigate to **Admin** > **Integrations** > **OAuth** and click **Add Client**.

   ![Add an OAuth client](images/2AAddOAuthClient.png "Add an OAuth client")

2. Enter a name for the OAuth client and select **Client Credentials** as the grant type. Click the **Roles** tab and assign the presence role for the OAuth client.

     ![Select the custom role and the grant type](images/2BOAuthClientSetup2.png "Select the custom role and the grant type")

3. Click **Save**. Copy the client ID and the client secret values for later use.

   ![Copy the client ID and client secret values](images/2COAuthClientCredentials2.png "Copy the client ID and client secret values")

4. Navigate to **Admin** > **Integrations** > **OAuth** and click **Add Client**.

  ![Add an OAuth client](images/2AAddOAuthClient.png "Add an OAuth client")

5. Enter a name for the OAuth client and select **Client Credentials** as the grant type. Click the **Roles** tab and assign the ConversationReadPublicAPI role for the OAuth client.

    ![Select the custom role and the grant type](images/2BOAuthClientSetup3.png "Select the custom role and the grant type")

6. Click **Save**. Copy the client ID and the client secret values for later use.

  ![Copy the client ID and client secret values](images/2COAuthClientCredentials3.png "Copy the client ID and client secret values")

### Add two Genesys Cloud data action integrations

To update a user's presence in Genesys Cloud, you call a Genesys Cloud public API. To enable this public API call, add a Genesys Cloud data actions integration.

1. Navigate to **Admin** > **Integrations** > **Integrations** and install the **Genesys Cloud Data Actions** integration. For more information, see [About the data actions integrations](https://help.mypurecloud.com/?p=209478 "Opens the About the data actions integrations article") in the Genesys Cloud Resource Center.

   ![Genesys Cloud Data Actions integration](images/3AGenesysCloudDataActionInstall.png "Genesys Cloud Data Actions integration")

2. Enter a name for the Genesys Cloud data action.

   ![Rename the data action](images/3BRenameDataAction.png "Rename the data action")

3. On the **Configuration** tab, click **Credentials** and then click **Configure**.

   ![Navigate to the OAuth credentials](images/3CAddOAuthCredentials.png "Navigate to the OAuth credentials")

4. Enter the client ID and client secret of the presence OAuth client that you in the previous step (#create-an-oauth-client-for-use-with-the-genesys-cloud-data-action-integration "Goes to the create an OAuth Client section"). Click **OK** and save the data action.

   ![Add OAuth client credentials](images/3DOAuthClientIDandSecret.png "Add OAuth client credentials")

5. Navigate to the main Integrations page and set the presence data action integration to **Active**.

   ![Set the presence data integration to active](images/3ESetToActive.png "Set the presence data action integration to active")

 To get the details of a conversation in Genesys Cloud, you call a Genesys Cloud public API. To enable this public API call, add a Genesys Cloud data actions integration.

6. Navigate to **Admin** > **Integrations** > **Integrations** and install the **Genesys Cloud Data Actions** integration. For more information, see [About the data actions integrations](https://help.mypurecloud.com/?p=209478 "Opens the About the data actions integrations article") in the Genesys Cloud Resource Center.

  ![Genesys Cloud Data Actions integration](images/3AGenesysCloudDataActionInstall.png "Genesys Cloud Data Actions integration")

7. Enter a name for the Genesys Cloud data action.

  ![Rename the data action](images/3BRenameDataAction2.png "Rename the data action")

8. On the **Configuration** tab, click **Credentials** and then click **Configure**.

  ![Navigate to the OAuth credentials](images/3DOAuthClientIDandSecret2.png "Navigate to the OAuth credentials")

9. Enter the client ID and client secret of the presence OAuth client that you in the previous step (#create-an-oauth-client-for-use-with-the-genesys-cloud-data-action-integration "Goes to the create an OAuth Client section"). Click **OK** and save the data action.

  ![Add OAuth client credentials](images/3CAddOAuthCredentials2.png "Add OAuth client credentials")

10. Navigate to the main Integrations page and set the presence data action integration to **Active**.

  ![Set the presence data integration to active](images/3ESetToActive2.png "Set the presence data action integration to active")

### Import five Genesys Cloud data actions

The GC User Presence data actions use the authenticated token that is supplied by the presence GC OAuth Client created in the previous step.

1. From the [update-gc-presence-on-communicate-call-activity-blueprint repo](https://github.com/GenesysCloudBlueprints/update-gc-presence-on-communicate-call-activity-blueprint) GitHub repository, download the GC-User-Presence-Update.custom.json file.

2. In Genesys Cloud, navigate to **Integrations** > **Actions** and click **Import**.

   ![Import the data action](images/4AImportDataActions.png "Import the data action")

3. Select the GC-User-Presence-Update.custom.json file and associate it with the **Update Genesys Cloud User Presence** integration that you created in the [Add a web services data actions integration](#add-a-web-services-data-actions-integration "Goes to the Add a web services data actions integration section") section, and then click **Import Action**.

   ![Import the Update Genesys Cloud User Presence data action](images/4BImportFindTeamsUserIdDataAction.png "Import the Update Genesys Cloud User Presence data action")

4. From the [update-gc-presence-on-communicate-call-activity-blueprint repo](https://github.com/GenesysCloudBlueprints/update-gc-presence-on-communicate-call-activity-blueprint) GitHub repository, download the Get-Genesys-Cloud-User-Presence.custom.json file.

5. In Genesys Cloud, navigate to **Integrations** > **Actions** and click **Import**.

  ![Import the data action](images/4AImportDataActions.png "Import the data action")

6. Select the GC-User-Presence-Update.custom.json file and associate it with the **Update Genesys Cloud User Presence** integration that you created in the [Add a web services data actions integration](#add-a-web-services-data-actions-integration "Goes to the Add a web services data actions integration section") section, and then click **Import Action**.

  ![Import the Update Genesys Cloud User Presence data action](images/4BImportFindTeamsUserIdDataAction2.png "Import the Get Genesys Cloud User Presence data action")

The GC conversation detail data actions use the authenticated token that is supplied by the conversation GC OAuth Client created in the previous step.

7. From the [update-gc-presence-on-communicate-call-activity-blueprint repo](https://github.com/GenesysCloudBlueprints/update-gc-presence-on-communicate-call-activity-blueprint) GitHub repository, download the GetInboundConversationDetailsForPickUp-Includes-Group-Check.custom.json file.

8. In Genesys Cloud, navigate to **Integrations** > **Actions** and click **Import**.

   ![Import the data action](images/4AImportDataActions.png "Import the data action")

9. Select the GetInboundConversationDetailsForPickUp-Includes-Group-Check.custom.json file and associate it with the **GetConversationDetailsPublicAPI** integration that you created in the [Add a web services data actions integration](#add-a-web-services-data-actions-integration "Goes to the Add a web services data actions integration section") section, and then click **Import Action**.

   ![Import the Update Genesys Cloud User Presence data action](images/4BImportFindTeamsUserIdDataAction3.png "Import the Inbound Conversation Details data action")

10. From the [update-gc-presence-on-communicate-call-activity-blueprint repo](https://github.com/GenesysCloudBlueprints/update-gc-presence-on-communicate-call-activity-blueprint) GitHub repository, download the GetOutboundConversationDetailsForPickUp.custom.json file.

11. In Genesys Cloud, navigate to **Integrations** > **Actions** and click **Import**.

  ![Import the data action](images/4AImportDataActions.png "Import the data action")

12. Select the GetOutboundConversationDetailsForPickUp.custom.json file and associate it with the **GetConversationDetailsPublicAPI** integration that you created in the [Add a web services data actions integration](#add-a-web-services-data-actions-integration "Goes to the Add a web services data actions integration section") section, and then click **Import Action**.

  ![Import the Update Genesys Cloud User Presence data action](images/4BImportFindTeamsUserIdDataAction4.png "Import the Outbound Conversation Details data action")

13. From the [update-gc-presence-on-communicate-call-activity-blueprint repo](https://github.com/GenesysCloudBlueprints/update-gc-presence-on-communicate-call-activity-blueprint) GitHub repository, download the GetInboundConversationCallsCheckForUserPickUp.custom.json file.

14. In Genesys Cloud, navigate to **Integrations** > **Actions** and click **Import**.

  ![Import the data action](images/4AImportDataActions.png "Import the data action")

15. Select the GetInboundConversationCallsCheckForUserPickUp.custom.json file and associate it with the **GetConversationDetailsPublicAPI** integration that you created in the [Add a web services data actions integration](#add-a-web-services-data-actions-integration "Goes to the Add a web services data actions integration section") section, and then click **Import Action**.

  ![Import the Update Genesys Cloud User Presence data action](images/4CImportFindTeamsUserIdDataAction5.png "Import the Inbound Conversation Calls data action")

### Import the Architect workflows

This solution includes two Architect workflows that use the data action you just created. This workflow updates the user's presence in Genesys Cloud:

* The **Set GC User to Busy.i3WorkFlow** workflow is triggered when a GC user makes or receives a Communicate call. This workflow sets the user's presence in Genesys Cloud to `Busy`.

* The **Set GC User to Available_v7-0.i3WorkFlow** workflow is triggered when a GC user leaves a Communicate call. This workflow sets the user's presence in Genesys Cloud to `Available`.

These workflows will be called by the event orchestration triggers, which you will create in the next section. When triggered, these Architect workflows will call the Update Genesys Cloud User Presence data action to update the Genesys Cloud user's presence.

First, import these workflows to your Genesys Cloud organization.

1. Download the **Set GC User to Busy.i3WorkFlow** file from the [update-gc-presence-on-communicate-call-activity-blueprint repo](https://github.com/GenesysCloudBlueprints/update-gc-presence-on-communicate-call-activity-blueprint) GitHub repository.

2. In Genesys Cloud, navigate to **Admin** > **Architect** > **Flows:Workflow** and click **Add**.

   ![Import the workflow](images/AddWorkflow1.png "Import the workflow")

3. Name your workflow and click **Create**.

  ![Name your workflow](images/NameWorkflow1.png "Name your workflow")

4. From the **Save** menu, click **Import**.

   ![Import the workflow](images/ImportWorkflow1.png "Import the workflow")

5. Select the downloaded **Set GC User to Busy.i3WorkFlow** file. Click **Import**.

   ![Import your workflow file](images/SelectWorkflow1ImportFile.png "Import your workflow file")

6. Modify the presence definition id. Click the **Call Data Action** boxes that use the **GC User Presence Update** data action.  In the **PRESENCE_DEFINITION_ID** box, paste the id of the desired Genesys Cloud presence value you'd like this workflow to set users to.

   ![Modify presence value](images/ModifyThePresenceDefinitionId1.png "Modify the presence definition id")

   :::primary
   **Note:** You can use the **GET /api/v2/presencedefinitions** GC Public API endpoint to find all your presence definition ids.  A link to the Genesys Cloud API explorer is in the Additional Resources section at the bottom of this blueprint.
   :::

7. Review your workflow. Copy the workflow ID from the URL and save it. You will need it to create the event orchestration trigger. After you have reviewed your workflow, click **Save** and then click **Publish**.

  ![Save your workflow](images/ImportedWorkflow1.png "Save your workflow")

8. Download the **Set GC User to Available.i3WorkFlow** file from the [update-gc-presence-on-communicate-call-activity-blueprint](https://github.com/GenesysCloudBlueprints/update-gc-presence-on-communicate-call-activity-blueprint) GitHub repository.  

9. In Genesys Cloud, navigate to **Admin** > **Architect** > **Flows:Workflow** and click **Add**.

  ![Import the script](images/AddWorkflow1.png "Import the script")

10. Name your workflow and click **Create**.

 ![Name your workflow](images/NameWorkflow2.png "Name your workflow")

11. From the **Save** menu, click **Import**.

  ![Import your workflow](images/ImportWorkflow2.png "Import your workflow")

12. Select the downloaded **Set GC User to Available_v1-0.i3WorkFlow** file. Click **Import**.

  ![Import your workflow file](images/SelectWorkflow2ImportFile.png "Import your workflow file")

13. Modify the presence definition id. Click the **Call Data Action** box that uses the **GC User Presence Update** data action.  In the **PRESENCE_DEFINITION_ID** box, paste the id of the desired Genesys Cloud presence value you'd like this workflow to set users to.

  ![Save your workflow](images/ModifyThePresenceDefinitionId2.png "Save your workflow")

  :::primary
  **Note:** You can use the **GET /api/v2/presencedefinitions** GC Public API endpoint to find all your presence definition ids.  A link to the Genesys Cloud API explorer is in the Additional Resources section at the bottom of this blueprint.
  :::

14. Review your workflow. Copy the workflow ID from the URL and save it. You will need it to create the event orchestration trigger. After you have reviewed your workflow, click **Save** and then click **Publish**.

  ![Save your workflow](images/ImportedWorkflow2.png "Save your workflow")

### Create an OAuth client for use for Event Orchestration trigger creation

To create the Event Orchestration triggers, use an OAuth client to configure authentication with the Genesys Cloud Public API.

1. Navigate to **Admin** > **Integrations** > **OAuth** and click **Add Client**.

   ![Add an OAuth client](images/2AAddOAuthClient.png "Add an OAuth client")

2. Enter a name for the OAuth client and select **Client Credentials** as the grant type. Click the **Roles** tab and assign the triggers role you created earlier in this blueprint for this OAuth client.

     ![Select the custom role and the grant type](images/2BOAuthClientSetup.png "Select the custom role and the grant type")

3. Click **Save**. Copy the client ID and the client secret values for later use.

   ![Copy the client ID and client secret values](images/2COAuthClientCredentials.png "Copy the client ID and client secret values")

## Create the event orchestration triggers

After you have created the workflows, create the triggers that call them. You need event orchestration activated in your Genesys Cloud organization and you need Postman running on your machine.

1. From the [update-gc-presence-on-communicate-call-activity-blueprint](https://github.com/GenesysCloudBlueprints/update-gc-presence-on-communicate-call-activity-blueprint) GitHub repository, download the Genesys Cloud Event Orchestration Trigger API's.postman_collection.json file.

2. In Postman, click **Import**

   ![Import the Event Orchestration API Collection](images/ImportPostmanCollection.png "Import the Event Orchestration API Collection")

3. Select the Genesys Cloud Event Orchestration Trigger API's.postman_collection.json file and click **Import**

   ![Import the Event Orchestration API Collection file](images/ImportPostmanCollectionFile.png "Import the Event Orchestration API Collection file")

4. In the Genesys Cloud Event Orchestration API's folder, select **Genesys Cloud Client Credential Token Creation**. Change your API domain to match the AWS region in which your Genesys Cloud organization is hosted. The Genesys Cloud organization in this screenshot is hosted in us-east-1.

5. Click the **Authorization** tab. In the **Username** field, paste the client ID from the [OAuth client that you created](#create-an-oauth-client-for-use-with-the-genesys-cloud-data-action-integration "Goes to the Create an OAuth client for use with the Genesys Cloud data action integration section"). In the **Password** field, paste the client secret from the same OAuth client. Click **Send**.

  ![Create the access token](images/CreateBearerToken.png "Create the access token")

6. From the body of the response, copy the **access token**.

     ![Copy the access token](images/CopyBearerToken.png "Copy the access token")

7. Click **ProcessAutomation Trigger Creation**. On the **Authentication** tab, select **Bearer Token** and paste the access token from the previous step.

     ![Paste the access token](images/PasteBearerToken.png "Paste the access token")

8. Click the **Body** tab. Be sure to change your API domain to match the AWS region your Genesys Cloud organization is hosted. Replace **my-workflow-id** with the id of the **Set GC User to Busy** Architect workflow that you created earlier in this blueprint. Click **Send**.

     ![Create the Conversation Start trigger](images/CreateTrigger1.png "Create the Conversation Start trigger")

     **Note:** If you'd like your JSON Body to match the screenshot, copy at paste the following JSON string.
     :::

     {
       "topicName":"v2.detail.events.conversation.{id}.user.start",
       "name": "GC Communicate Call User Start",
       "target":{
         "id": "my-workflow-id",
         "type": "Workflow" },
         "matchCriteria": [
            {
             "jsonPath": "queueId",
             "operator": "Exists",
             "value": false
             }
             ],
         "enabled": true
     }

9. To create the second trigger, replace **my-workflow-id** with the ID of the **Set GC User to Available** Architect workflow that you created earlier in this blueprint. Repeat the actions defined in step 8 and use the JSON body sample below to match the screenshot.  Click **Send**.

    ![Create the Conversation Start trigger](images/CreateTrigger2.png "Create the Conversation Start trigger")

    **Note:** If you'd like your JSON Body to match the screenshot, copy at paste the following JSON string.  Modify the IN operator values to match you business requirements.
    :::

    {
      "topicName":"v2.detail.events.conversation.{id}.user.end",
      "name": "GC Communicate Call User End",
      "target":{
        "id": "my-workflow-id",
        "type": "Workflow" },
        "matchCriteria": [
           {
            "jsonPath": "queueId",
            "operator": "Exists",
            "value": false
            }
            ],
        "enabled": true
    }


## Additional resources

* [Genesys Cloud API Explorer](https://developer.genesys.cloud/devapps/api-explorer "Opens the GC API Explorer")
* [Genesys Cloud notification triggers ("Available topics")](https://developer.genesys.cloud/notificationsalerts/notifications/available-topics "Opens the Available topics page")
* [Prefixes for AWS regions](https://developer.genesys.cloud/platform/api/ "Open the Overview page in the API section of the Genesys Cloud Developer Center")
* [Postman API Platform](https://www.postman.com/ "Goes to the Postman API Platform page") in the Postman documentation
* [update-gc-presence-on-communicate-call-activity-blueprint repo](https://github.com/GenesysCloudBlueprints/update-gc-presence-on-communicate-call-activity-blueprint "Opens the GitHub repo")
