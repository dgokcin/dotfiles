---
name: aws-debug
description: This skill should be used when the user asks to "debug AWS", "check AWS resources", "why is my Lambda failing", "S3 bucket access issues", "EC2 instance status", "RDS connection problems", "check CloudWatch logs", or mentions any AWS service debugging. Automatically selects a read-only profile first and falls back to admin if the command fails with a permissions error.
argument-hint: <service/resource> [profile] [region]
allowed-tools:
  - Bash(aws:*)
  - Bash(cat /tmp/aws-debug-profiles.json:*)
  - Bash(jq:*)
  - Bash(echo:*)
  - Bash(mv:*)
---

# AWS Debug

Debug AWS resources using AWS CLI with automatic profile management. Prefers read-only
profiles for safety; falls back to admin profile when a command returns a permissions error.

## Bootstrap — Profile Setup

Config file: `/tmp/aws-debug-profiles.json`

### Step 1: Check for existing config

```bash
cat /tmp/aws-debug-profiles.json 2>/dev/null
```

If file exists and `selected.readonly` + `selected.admin` are set → skip to "Ready to Debug".

### Step 2: Discover all profiles (first run only)

```bash
aws configure list-profiles
```

Classify each by name:
- **readonly candidates**: name contains `readonly`, `read-only`, `ro`, `viewer`, `auditor`, `read`
- **admin candidates**: everything else (`admin`, `default`, `full`, `power`, unrecognized)

### Step 3: Ask user to confirm selections

Present classified list. Ask user to confirm or override:
- Which profile to use as **readonly** (primary)
- Which profile to use as **admin** (fallback)

If only one profile exists → use it for both roles.

### Step 4: Write config JSON

```bash
cat > /tmp/aws-debug-profiles.json <<'EOF'
{
  "profiles": [
    {"name": "<profile1>", "role": "readonly"},
    {"name": "<profile2>", "role": "admin"}
  ],
  "selected": {
    "readonly": "<readonly-profile>",
    "admin": "<admin-profile>"
  }
}
EOF
```

## Ready to Debug

```bash
cat /tmp/aws-debug-profiles.json
```

Extract selected profiles with `jq` (preferred) or `grep`:
```bash
READONLY=$(jq -r '.selected.readonly' /tmp/aws-debug-profiles.json)
ADMIN=$(jq -r '.selected.admin' /tmp/aws-debug-profiles.json)
```

**If aws NOT FOUND** → stop, tell user: `aws` CLI required (`brew install awscli`).

## Usage Pattern

Always try readonly first:

```bash
aws --profile "$READONLY" <service> <command>
```

If output contains `AccessDenied`, `UnauthorizedOperation`, or `is not authorized` → retry with admin:

```bash
aws --profile "$ADMIN" <service> <command>
```

Note fallback in output: `(admin profile used — readonly lacked permission)`

## Diagnose by Service

### EC2
1. Instance state: `aws ec2 describe-instances --instance-ids <id>`
2. Status checks: `aws ec2 describe-instance-status --instance-ids <id>`
3. Security groups: `aws ec2 describe-security-groups --group-ids <sg-id>`

### Lambda
1. Function config: `aws lambda get-function --function-name <name>`
2. Recent invocations: `aws logs filter-log-events --log-group-name /aws/lambda/<name> --limit 50`
3. Errors: filter for "ERROR" or "Task timed out"

### S3
1. Bucket policy: `aws s3api get-bucket-policy --bucket <name>`
2. Access: `aws s3 ls s3://<bucket>/`
3. ACL: `aws s3api get-bucket-acl --bucket <name>`

### RDS
1. Instance status: `aws rds describe-db-instances --db-instance-identifier <id>`
2. Events: `aws rds describe-events --source-identifier <id> --source-type db-instance`
3. Logs: `aws rds describe-db-log-files --db-instance-identifier <id>`

### CloudWatch
1. Alarms: `aws cloudwatch describe-alarms --state-value ALARM`
2. Metrics: `aws cloudwatch get-metric-statistics ...`
3. Log insights: `aws logs start-query ...`

### IAM
1. User policies: `aws iam list-attached-user-policies --user-name <name>`
2. Role policies: `aws iam list-attached-role-policies --role-name <name>`
3. Policy document: `aws iam get-policy-version --policy-arn <arn> --version-id v1`

## Report Format

```markdown
## AWS Investigation: <service> (<profile> / <region>)

**Resource:** <identifier>

### Status
<current state, health, relevant config>

### Issue Found
<specific problem with evidence: error message, misconfiguration, permission denied>

### Evidence
- API response: <relevant fields>
- Logs: <error lines>
- Config: <problematic setting>

### Recommended Fix
- <specific action to resolve>
- <AWS Console path or CLI command for user to run>
```

## Rules

- **Profile required** — never run AWS commands without profile set
- **Read-only default** — describe/get/list commands only; suggest mutations, don't execute
- **Bound output** — use `--limit`, `--max-items`, or pipe to `head` for large results
- **Confirm destructive** — if user asks for modify/delete, print command but don't run
- **Region awareness** — use `--region` when resource is region-specific

## Change Profile

User says "switch profile", "use different profile", or "change readonly/admin profile":

1. Show current config: `cat /tmp/aws-debug-profiles.json`
2. Ask which role to change and what to set it to
3. Update with `jq`:
   ```bash
   jq '.selected.readonly = "<new>"' /tmp/aws-debug-profiles.json > /tmp/aws-debug-profiles.json.tmp \
     && mv /tmp/aws-debug-profiles.json.tmp /tmp/aws-debug-profiles.json
   ```
   (replace `.selected.readonly` with `.selected.admin` as needed)

To re-run full discovery: `rm /tmp/aws-debug-profiles.json` then restart skill.
