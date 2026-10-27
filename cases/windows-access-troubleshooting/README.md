# Windows Access Administration and Troubleshooting: Technical Lab

## Overview

Built a Windows Active Directory lab in Azure, set up group-based access to departmental shares, then diagnosed and fixed a controlled access failure.

Access was restored without changing any resource permissions. A read-only PowerShell helper checks account state and group membership.

## Environment and Access Model

| Component | Configuration |
|---|---|
| Hosting | Microsoft Azure, isolated virtual network (`10.0.0.0/24`) |
| Domain controller | `dc01`: Windows Server 2022 Datacenter Azure Edition, AD DS and DNS |
| Client | `client01`: Windows 11 Enterprise, domain joined |
| Domain | `northstar.test` (`NORTHSTAR`) |
| Domain controller IP | `10.0.0.4` |
| Administrative access | Azure Bastion Developer |

Neither VM had a public IP or directly exposed Internet-facing RDP.

The domain controller's private IP was configured at the Azure virtual NIC level while Windows remained DHCP-configured. The client used `dc01` for domain DNS resolution.

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

The controlled fault: Alice was removed from `SG_Operations_Access`. The account, network, DNS and resource permissions were left unchanged.

After refreshing Alice's logon session, access to `\\dc01\Operations` was denied even though domain authentication remained successful.

### Investigation and Root Cause

The checks separated four possible causes: authentication, connectivity, group membership and resource permissions.

| Diagnostic area | Findings |
|---|---|
| Account/authentication | Account enabled, not locked, password valid, domain authentication successful |
| DNS/DC discovery | `dc01.northstar.test` resolved to `10.0.0.4`; domain-controller discovery succeeded |
| Network/SMB | TCP port 445 reachable |
| Resource permissions | Operations share and NTFS permissions unchanged |
| Group membership | Alice missing from `SG_Operations_Access` |

**Root cause:** An authorization failure caused by missing Active Directory security-group membership.

The account could authenticate, the resource remained reachable, and its permissions were intact. The one difference from the healthy baseline was Alice's missing membership in the group authorized to access Operations.

Evidence: [access failure and client diagnostics](evidence/08-operations-failure-client-diagnostics.png), [account and group diagnosis](evidence/09-account-and-group-diagnosis.png), and [resource permissions intact](evidence/10-operations-permissions-intact.png).

### Security-Context Behavior

A later test showed that removing Alice from the group did not cut off her existing session. Access stayed allowed until she signed out and back in.

So a group-membership change may not take effect until the user signs in again and gets a new security token.

## Remediation and Validation

Alice was restored to `SG_Operations_Access`. No changes were made to the SMB share or NTFS permissions.

After a full sign-out/sign-in, the intended access model was retested:

| Validation | Expected | Observed |
|---|---|---|
| Operations access | ALLOW | **ALLOW** |
| Finance access | DENY | **DENY** |

Access was restored without widening permissions to the Finance share.

Evidence: [Operations access restored](evidence/11-operations-access-restored.png) and [Finance access still denied](evidence/12-finance-access-still-denied.png).

## Supporting Artifacts

### Operational Records

Two simulated records show how the access request and the incident were handled:

- [Access Request](records/access-request.md): requested access, group assignment, authorization assumption, and validation.
- [Access Incident](records/access-incident.md): failure symptoms, diagnostic evidence, root cause, remediation, and closure.

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

The helper only reads from the directory. It changes no AD objects or permissions.

### Evidence and Diagram

- [Environment and access-model diagram](diagram/environment.md)
- [Selected screenshots and validation evidence](evidence/)
