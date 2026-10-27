# Operations Casebook

Technical casework demonstrating practical systems administration, access control, structured troubleshooting, endpoint investigation, and validated outcomes.

Each case documents the environment, technical problem, investigation, outcome, and supporting evidence.

## Cases

### [Windows Access Administration and Troubleshooting: Technical Lab](cases/windows-access-troubleshooting/README.md)

Configured Active Directory group-based access to departmental SMB resources in an Azure-hosted Windows environment.

Investigated a controlled access failure by checking authentication, DNS and SMB connectivity, security-group membership, and resource permissions. Identified and corrected the authorization issue, then verified that intended access was restored while unrelated resources remained restricted.

**Supporting artifacts:** Environment diagram, diagnostic screenshots, operational records, and a tested read-only PowerShell access-reporting script.

[View the complete technical case →](cases/windows-access-troubleshooting/README.md)

### [Endpoint Telemetry and Investigation: Technical Lab](cases/endpoint-telemetry-investigation/README.md)

Configured Sysmon process-creation telemetry on a Windows endpoint and collected it centrally in Wazuh across private Azure networking.

Investigated a controlled encoded PowerShell execution by correlating local and central event records, decoding the executed command, and testing an encoded-command detection check against an ordinary-command comparison. Triaged the resulting level-12 Wazuh alert and closed it as authorized activity based on the correlated evidence.

**Supporting artifacts:** Telemetry-flow diagram, correlated event evidence, detection validation results, an investigation timeline, and configuration files.

[View the complete technical case →](cases/endpoint-telemetry-investigation/README.md)

## Provenance

Lab architecture, configuration, testing, investigation, remediation, and validation were performed and verified by the author. AI tools were used for documentation drafting, script and configuration scaffolding, and code review.
