param(
    [Parameter(Mandatory = $true)]
    [string]$Identity,

    [string]$RequiredGroup = "SG_Operations_Access"
)

try {
    $user = Get-ADUser `
        -Identity $Identity `
        -Properties Enabled, LockedOut, PasswordExpired, MemberOf `
        -ErrorAction Stop

    $groups = @(
        $user.MemberOf |
        ForEach-Object {
            (Get-ADGroup -Identity $_).Name
        } |
        Sort-Object
    )

    $isMember = $groups -contains $RequiredGroup

    [PSCustomObject]@{
        SamAccountName  = $user.SamAccountName
        Enabled         = $user.Enabled
        LockedOut       = $user.LockedOut
        PasswordExpired = $user.PasswordExpired
        RequiredGroup   = $RequiredGroup
        IsMember        = $isMember
        Groups          = if ($groups.Count -gt 0) {
            $groups -join ", "
        }
        else {
            "(none)"
        }
    }
}
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    Write-Error "Active Directory user '$Identity' was not found."
}
catch {
    Write-Error "Unable to retrieve '$Identity': $($_.Exception.Message)"
}
