Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
function show-messagebox {
param (
    [string]$Message,
    [string]$Title = "Password expiration notification",
    [string]$buttons = 'OK'
)
# This function displays a message box by calling the .Net Windows.Forms (MessageBox class)

#Load the assembly
Add-Type -AssemblyName System.Windows.Forms
$MessageIcon = [System.Windows.MessageBoxImage]::Information

# Define the button types
switch ($buttons) {
   'ok' {$btn = [System.Windows.Forms.MessageBoxButtons]::OK; break}
   'okcancel' {$btn = [System.Windows.Forms.MessageBoxButtons]::OKCancel; break}
   'AbortRetryIgnore' {$btn = [System.Windows.Forms.MessageBoxButtons]::AbortRetryIgnore; break}
   'YesNoCancel' {$btn = [System.Windows.Forms.MessageBoxButtons]::YesNoCancel; break}
   'YesNo' {$btn = [System.Windows.Forms.MessageBoxButtons]::yesno; break}
   'RetryCancel'{$btn = [System.Windows.Forms.MessageBoxButtons]::RetryCancel; break}
   default {$btn = [System.Windows.Forms.MessageBoxButtons]::RetryCancel; break}
}

  # Display the message box
  Add-Type -AssemblyName System.Windows.Forms | Out-Null
  $Return=[System.Windows.Forms.MessageBox]::Show($Message,$Title,$buttons,$messageicon)
  $Return
}


$adsisearcher = New-Object system.directoryservices.directorysearcher "name=$env:username"
$user=$adsisearcher.FindOne()
$changed=[datetime]::fromfiletime($user.properties.pwdlastset[0])
$today=Get-Date
$diff=New-TimeSpan $today.AddDays(-90) $today

    Switch ($diff.days)
    {
       {$_ -lt 80} {"Password expiration is not within 10 days";break}
       {$_ -gt 80 -and $_ -lt 89} {$message=`
        @"
        Your password will expire in $(90 - $diff.days) days
        Please press "OK" Then press "Ctrl+Alt+Del"
        to change your password
"@
        show-messagebox -Message $message}

    {$_ -eq 89} {$message=`
        @"
        Your password will expire in 1 day
        Please press "OK" Then press "Ctrl+Alt+Del"
        to change your password
"@
        show-messagebox -Message $message}

        {$_ -eq 90} {$message=
        @"
        Your password expires today
        Please press "OK" Then press "Ctrl+Alt+Del"
        to change your password immediatly
"@
        show-messagebox -Message $message}
    }