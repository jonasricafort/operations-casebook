# Encoded-command detection predicate, as first written and validated.
# The positive and comparison runs evaluated the same conditions
# individually, as shown in the manual-query evidence screenshots.
#
# Applied on wazuh01 to stored Wazuh alerts in
# /var/ossec/logs/alerts/alerts.json (one JSON alert per line).
# Each alert record was parsed with json.loads and passed to matches().
# The harness that loaded the file and reported results is not included.

import re


def matches(record):
    win = record.get("data", {}).get("win", {})
    system = win.get("system", {})
    event = win.get("eventdata", {})

    command = event.get("commandLine") or ""
    image = event.get("image") or ""

    return (
        str(record.get("agent", {}).get("id")).zfill(3) == "001"
        and str(system.get("eventID")) == "1"
        and system.get("providerName") == "Microsoft-Windows-Sysmon"
        and image.lower().endswith("\\powershell.exe")
        and re.search(
            r"(?<!\S)-EncodedCommand(?=\s|$)",
            command,
            re.IGNORECASE
        ) is not None
    )
