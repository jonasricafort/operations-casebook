# Access Incident

**Lab simulation**

## Symptom

`NORTHSTAR\operations.alice` could authenticate to the `northstar.test` domain but could no longer access the Operations shared resource:

`\\dc01\Operations`

The same user had successfully accessed the resource during the earlier healthy baseline.

## Scope

The issue affected the Operations resource access path for `operations.alice`.

The investigation focused on whether the failure originated from:

- account or authentication state;
- DNS or network connectivity;
- SMB availability;
- security-group membership;
- share permissions;
- NTFS permissions.

## Investigation

Client-side checks confirmed that Alice remained signed in as the expected domain user and that domain connectivity was functioning.

DNS continued to resolve `dc01.northstar.test`, and TCP connectivity to SMB on `dc01` remained available.

The user account was enabled and usable.

The Operations share and NTFS permissions were unchanged and continued to grant access to `SG_Operations_Access`.

A membership check then showed:

`operations.alice` → not a member of `SG_Operations_Access`

This differed from the known-good baseline.

## Root Cause

The access failure was caused by missing security-group membership.

`operations.alice` was no longer a member of `SG_Operations_Access`, so her refreshed security context no longer contained the group that was authorized by the Operations share and NTFS permissions.

The evidence did not indicate an authentication, DNS, network, SMB, share-permission, or NTFS-permission failure.

## Correction

`operations.alice` was restored to:

`SG_Operations_Access`

The resource permissions themselves were not changed.

Alice then signed out and signed back in so Windows could obtain a refreshed security token containing the restored group membership.

## Validation

After correction and security-context refresh:

| Resource | Expected | Observed |
|---|---|---|
| `\\dc01\Operations` | ALLOW | ALLOW |
| `\\dc01\Finance` | DENY | DENY |

Authorized Operations access was restored without broadening access to the unrelated Finance resource.

## Evidence

- [Healthy Operations access](../evidence/06-operations-access-allowed.png)
- [Healthy Finance denial](../evidence/07-finance-access-denied.png)
- [Failed-state client diagnostics](../evidence/08-operations-failure-client-diagnostics.png)
- [Account and group diagnosis](../evidence/09-account-and-group-diagnosis.png)
- [Operations permissions intact](../evidence/10-operations-permissions-intact.png)
- [Operations access restored](../evidence/11-operations-access-restored.png)
- [Finance access still denied](../evidence/12-finance-access-still-denied.png)

## Closure

The intended access state was restored and validated. No unresolved issue or escalation remained for this scenario.
