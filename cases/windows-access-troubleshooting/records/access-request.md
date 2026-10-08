# Access Request

**Lab simulation**

## Request

Provide `operations.alice` read access to the Operations shared resource while keeping the Finance resource restricted.

## Authorization Basis

The lab access model assigns `operations.alice` to the Operations access group:

`operations.alice` → `SG_Operations_Access`

Access to departmental resources is granted through security-group membership rather than direct user permissions.

## Implementation

`operations.alice` was assigned to `SG_Operations_Access`.

The Operations resource is available at:

`\\dc01\Operations`

Access is controlled through:

- SMB share permission for `SG_Operations_Access`
- NTFS Read & Execute permission for `SG_Operations_Access`

No direct resource permission was assigned to `operations.alice`.

## Validation

Testing from the domain-joined `client01` system as `NORTHSTAR\operations.alice` confirmed:

| Resource | Expected | Observed |
|---|---|---|
| `\\dc01\Operations` | ALLOW | ALLOW |
| `\\dc01\Finance` | DENY | DENY |

The requested Operations access worked, while the unrelated Finance resource remained restricted.

## Evidence

- [Operations access allowed](../evidence/06-operations-access-allowed.png)
- [Finance access denied](../evidence/07-finance-access-denied.png)

## Closure

Requested access was successfully implemented and validated. The user's access remained limited to the intended departmental resource.
