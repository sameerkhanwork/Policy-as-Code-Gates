package main
 
import rego.v1
 
# 1. Enforce IRSA Annotation on Service Accounts
deny contains msg if {
# Find all resources in the plan
resource := input.resource_changes[_]
 
# Filter: We only care about Kubernetes Service Accounts
resource.type == "kubernetes_service_account"
 
# Ignore resources that are being deleted
resource.change.actions[_] != "delete"
 
# Safe navigation to get annotations
annotations := object.get(resource.change.after.metadata[0], "annotations", {})
 
# Rule: If the specific IRSA annotation is missing, deny it.
not annotations["eks.amazonaws.com/role-arn"]
 
# The error message
msg := sprintf(
"VIOLATION: ServiceAccount '%v' is missing the IRSA annotation 'eks.amazonaws.com/role-arn'. You must use IAM Roles for Service Accounts, not node roles or keys.",
[resource.address],
)
}
 
# 2. Block Hardcoded AWS Keys (Force IRSA Usage)
deny contains msg if {
resource := input.resource_changes[_]
resource.type == "kubernetes_deployment"
resource.change.actions[_] != "delete"
 
# Drill down into the container definitions
container := resource.change.after.spec[0].template[0].spec[0].container[_]
# Check env vars (handle case where env might be missing/null)
env_vars := object.get(container, "env", [])
env_var := env_vars[_]
 
# Rule: specific check for bad environment variables
env_var.name == "AWS_ACCESS_KEY_ID"
 
msg := sprintf(
"VIOLATION: Hardcoded AWS Credential '%v' found in Deployment '%v'. Do not use Access Keys. Use IRSA (IAM Roles for Service Accounts) instead.",
[env_var.name, resource.address],
)
}