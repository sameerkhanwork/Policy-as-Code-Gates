# **Policy-as-Code Gates**

This repository implements automated policy enforcement for our cloud infrastructure. It ensures that all Terraform code meets our security and organizational standards before it can be deployed.

## **🛡️ The Gates**

We use two tools to enforce policies:

1. **Conftest (OPA):** Enforces custom organizational rules.  
2. **Checkov:** Enforces standard security best practices.

### **Active Policies**

| Tool | Policy Name | Description |
| :---- | :---- | :---- |
| **Conftest** | IRSA-Only | **Blocker.** AWS Keys are forbidden in Deployments. ServiceAccounts must have the eks.amazonaws.com/role-arn annotation. |
| **Conftest** | Required Tags | **Blocker.** All resources must have specific cost-center tags (defined in policy/tags.rego). |
| **Checkov** | Public S3 | **Blocker.** S3 buckets cannot be publicly accessible. |
| **Checkov** | Encryption | **Blocker.** EBS volumes and S3 buckets must be encrypted (KMS). |

## **🚀 Usage Guide**

### **1\. How to run locally**

Before pushing code, run these commands to check your work.  
**Prerequisites:**

* [Install Conftest](https://www.conftest.dev/install/)  
* pip install checkov

**Step 1: Generate Plan JSON**  
`terraform init`  
`terraform plan -out=tfplan.binary`  
`terraform show -json tfplan.binary > tfplan.json`

**Step 2: Run Custom Policy Check (Conftest)**  
`conftest test tfplan.json -p policy/`

**Step 3: Run Security Check (Checkov)**  
`checkov -f main.tf`

### **2\. CI/CD Integration**

The pipeline is defined in .github/workflows/policy-check.yaml.

* It runs automatically on every **Pull Request**.  
* If *any* policy fails, the PR status will be red, and merging is blocked.

## **🏳️ Waiver Process (Bypassing Checks)**

If you have a valid business reason to violate a policy, you must document it in the code.  
**To bypass a Checkov rule:** Add a comment inside the resource block:  
`resource "aws_s3_bucket" "public_bucket" {`  
  `# checkov:skip=CKV_AWS_20: This bucket hosts the public website assets`  
  `bucket = "my-public-website"`  
  `acl    = "public-read"`  
`}`

**To bypass a Conftest rule:** You must update the Rego policy in policy/ to exclude your specific resource ID, and get approval from the Security team on the PR.