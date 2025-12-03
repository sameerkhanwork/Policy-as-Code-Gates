package main

import rego.v1

# Use 'contains' for set rules and 'if' before the body
deny contains msg if {
  resource := input.resource_changes[_]

  # Filter for create/update actions
  action := resource.change.actions[_]
  action != "delete"
  action != "no-op"

  # Safely get tags (defaults to {})
  tags := object.get(resource.change.after, "tags", {})

  # Check if CostCenter is missing
  not tags.CostCenter

  msg := sprintf("Resource '%v' is missing the required 'CostCenter' tag.", [resource.address])
}