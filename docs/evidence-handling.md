# Evidence Handling

This repository contains sanitized evidence from technical lab casework.

## Evidence classes

### Private raw evidence
Raw screenshots, notes, exports, identifiers, and other working material are kept outside the Git repository.

Private evidence may contain information that is useful during validation but is unnecessary or inappropriate for publication.

### Publishable evidence
Only sanitized technical evidence needed to demonstrate the completed lab workflow is added to this repository.

Publishable evidence should be the smallest set necessary to support the documented result.

## Never publish

Remove or redact:

- passwords and credentials;
- API keys, tokens, secrets, and recovery information;
- MFA setup data or recovery codes;
- payment and billing identifiers;
- personal contact or account information that is not required for the case;
- tenant IDs, subscription IDs, public IP addresses, and other infrastructure identifiers unless technically necessary;
- unrelated browser tabs, notifications, filenames, account names, or private content;
- any identifier that unnecessarily links this professional repository to unrelated personal or pseudonymous activity.

## Synthetic lab data

The case uses fictional users, groups, resources, and organization data where practical.

Synthetic technical evidence may be published when it accurately represents work actually performed in the lab.

Synthetic evidence must not be presented as production or client evidence.

## Screenshot handling

Before publishing a screenshot:

1. crop it to the relevant technical content;
2. review the entire visible area for sensitive or unnecessary information;
3. redact only where needed;
4. verify that the redaction cannot be trivially reversed;
5. save the sanitized copy separately from the raw original.

## Publication rule

Raw evidence stays private.

Only sanitized evidence that directly supports the documented case is committed to the repository.

When uncertain, omit the artifact rather than publish unnecessary sensitive information.
