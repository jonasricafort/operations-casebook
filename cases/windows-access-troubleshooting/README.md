# Windows Access Administration and Troubleshooting: Lab Case

## Overview

Built and tested a Windows Active Directory lab to demonstrate group-based access administration, systematic troubleshooting, and validated remediation.

The case covers configuring departmental resource access, diagnosing a controlled authorization failure, and restoring access without unnecessarily modifying resource permissions. A read-only PowerShell helper supports account and group-membership inspection.

## Environment and Access Model

| Component | Configuration |
|---|---|
| Hosting | Microsoft Azure, isolated virtual network (`10.0.0.0/24`) |
| Domain controller | `dc01` — Windows Server 2022 Datacenter Azure Edition, AD DS and DNS |
| Client | `client01` — Windows 11 Enterprise, domain joined |
| Domain | `northstar.test` (`NORTHSTAR`) |
| Domain controller IP | `10.0.0.4` |
| Administrative access | Azure Bastion Developer |

Neither VM has a public IP or directly exposed Internet-facing RDP.

The domain controller's private IP is configured at the Azure virtual NIC level while Windows remains DHCP-configured. The client uses `dc01` for domain DNS resolution.

**Group-based authorization:**

| User | Security group | Authorized resource |
|---|---|---|
| `operations.alice` | `SG_Operations_Access` | `\\dc01\Operations` |
| `finance.chris` | `SG_Finance_Access` | `\\dc01\Finance` |

Each departmental resource grants its corresponding security group **Read** permission at the SMB share level and **Read & Execute** through NTFS permissions.

No direct resource permissions are assigned to Alice or Chris, and no explicit DENY entries are used.

**Authorization path:**

`User → AD security group → SMB share permissions + NTFS ACL → Effective access`

The investigation and validation focused on Alice. Chris's reciprocal access path was configured but not separately tested.

[View environment and authorization diagram](diagram/environment.md)

## Troubleshooting Case

### Baseline and Controlled Failure

The healthy baseline was established from `client01`, signed in as `NORTHSTAR\operations.alice`.

| Resource | Expected | Observed |
|---|---|---|
| `\\dc01\Operations` | ALLOW | **ALLOW** |
| `\\dc01\Finance` | DENY | **DENY** |

A controlled fault was introduced by removing Alice from `SG_Operations_Access`, leaving the account, network, DNS, and resource permissions unchanged.

After refreshing Alice's logon session, access to `\\dc01\Operations` was denied even though domain authentication remained successful.

### Investigation and Root Cause

The investigation distinguished authentication, connectivity, membership, and resource-permission failures.

| Diagnostic area | Findings |
|---|---|
| Account/authentication | Account enabled, not locked, password valid, domain authentication successful |
| DNS/DC discovery | `dc01.northstar.test` resolved to `10.0.0.4`; domain-controller discovery succeeded |
| Network/SMB | TCP port 445 reachable |
| Resource permissions | Operations share and NTFS permissions unchanged |
| Group membership | Alice missing from `SG_Operations_Access` |

**Root cause:** An authorization failure caused by missing Active Directory security-group membership.

The account could authenticate, the resource remained reachable, and its permissions were intact. The decisive difference from the healthy baseline was Alice's missing membership in the group authorized to access Operations.

**Supporting diagnostic evidence:**

- [Access failure and client diagnostics](evidence/08-operations-failure-client-diagnostics.png)
- [Account and group diagnosis](evidence/09-account-and-group-diagnosis.png)
- [Resource permissions remained intact](evidence/10-operations-permissions-intact.png)

### Security-Context Behavior

A subsequent test demonstrated that removing Alice's group membership did not immediately revoke access from her existing logged-in session. Access remained allowed until she signed out and back in.

This illustrates why Active Directory membership changes may require a refreshed logon/security context before the new authorization state is observed.

## Remediation and Validation

Alice was restored to `SG_Operations_Access`. No changes were made to the SMB share or NTFS permissions.

After a full sign-out/sign-in, the intended access model was retested:

| Validation | Expected | Observed |
|---|---|---|
| Operations access | ALLOW | **ALLOW** |
| Finance access | DENY | **DENY** |

The correction restored the required access without broadening permissions to the unrelated departmental resource.

**Validation evidence:**

- [Operations access restored](evidence/11-operations-access-restored.png)
- [Finance access remains denied](evidence/12-finance-access-still-denied.png)

**Validated workflow:**

`Healthy baseline → Controlled fault → Diagnosis → Root cause → Correction → Positive and negative retesting`

## Supporting Artifacts

### Operational Records

Two simulated operational records document the access-administration and incident-resolution workflows:

- [Access Request](records/access-request.md) — requested access, group assignment, authorization assumption, and validation.
- [Access Incident](records/access-incident.md) — failure symptoms, diagnostic evidence, root cause, remediation, and closure.

### PowerShell Access Report

[Get-ADUserAccessReport.ps1](scripts/Get-ADUserAccessReport.ps1)

A read-only PowerShell helper that inspects:

- AD user state, including enabled, locked, and password-expiration status.
- Direct security-group memberships.
- Membership in a specified required group using `-RequiredGroup`.
- Invalid or nonexistent usernames with controlled error handling.

**Validated checks:**

| Input | Result |
|---|---|
| Alice / `SG_Operations_Access` | `IsMember = True` |
| Alice / `SG_Finance_Access` | `IsMember = False` |
| Nonexistent user | Controlled user-not-found error |

The helper performs directory reads and comparisons without changing AD objects or resource permissions.

### Evidence and Diagram

- [Environment and access-model diagram](diagram/environment.md)
- [Selected screenshots and validation evidence](evidence/)

## Provenance

Lab architecture, Active Directory and access-control configuration, fault injection, diagnostic testing, remediation, and validation were performed and verified by the author. AI tools were used for documentation drafting and code review.
