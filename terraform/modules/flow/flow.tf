resource "genesyscloud_flow" "inbound_call_flow" {
  filepath = "${path.module}/blacklist.yaml"
  file_content_hash = filesha256("${path.module}/blacklist.yaml")
  substitutions = {
    flow_name               = "Blacklist"
    division                = "Home"
    default_language        = "en-us"
    data_action_category    = var.data_action_category
    data_action_name        = var.data_action_name
    data_table              = var.data_table_name
  }
}