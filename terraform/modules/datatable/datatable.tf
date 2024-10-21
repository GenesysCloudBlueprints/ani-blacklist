/*
  Creates the datatable
*/
resource "genesyscloud_architect_datatable" "agent_score" {
  name        = "Blacklist"
  properties {
    name  = "key"
    type  = "string"
    title = "ani"
  }
}
