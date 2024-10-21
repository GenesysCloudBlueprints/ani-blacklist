resource "genesyscloud_processautomation_trigger" "example-trigger" {
  name       = "Blacklist"
  topic_name = "v2.detail.events.conversation.{id}.customer.start"
  enabled    = true
  target {
    id   = var.workflow_id
    type = "Workflow"
    workflow_target_settings {
      data_format = "TopLevelPrimitives"
    }
  }
  match_criteria = jsonencode([
    {
      "jsonPath" : "mediaType",
      "operator" : "Equal",
      "value" : "VOICE"
    }
  ])
  event_ttl_seconds = 60
}