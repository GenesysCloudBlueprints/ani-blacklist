// Create a Data Table
module "data_table" {
  source             = "./modules/datatable"
}

// Create a Data Action integration
module "data_action" {
  source                          = "git::https://github.com/GenesysCloudDevOps/public-api-data-actions-integration-module?ref=main"
  integration_name                = "Disconnect Interaction"
  integration_creds_client_id     = var.client_id
  integration_creds_client_secret = var.client_secret
}

// Create a Get Agent ID Data Action
module "get_agent_id_data_action" {
  source             = "./modules/actions/disconnect-interaction"
  action_name        = "Disconnect Interaction"
  action_category    = "${module.data_action.integration_name}"
  integration_id     = "${module.data_action.integration_id}"
}

// Configures the architect inbound call flow
module "archy_flow" {
  source                = "./modules/flow"
  data_action_category  = module.data_action.integration_name
  data_action_name      = module.get_agent_id_data_action.action_name
  data_table_name       = module.data_table.datatable_name
}

// Create a Trigger
module "trigger" {
  source       = "./modules/trigger"
  workflow_id  = module.archy_flow.flow_id
  depends_on = [ module.archy_flow ]
}
