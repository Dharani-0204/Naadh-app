$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "cmd.exe"
$pinfo.Arguments = "/c C:\Users\karla\AppData\Local\Android\sdk\cmdline-tools\latest\bin\sdkmanager.bat --licenses"
$pinfo.RedirectStandardInput = $true
$pinfo.RedirectStandardOutput = $false
$pinfo.RedirectStandardError = $false
$pinfo.UseShellExecute = $false

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $pinfo
$process.Start() | Out-Null

# Wait for sdkmanager to load and display first prompt
Start-Sleep -Seconds 12

# Send y for "Review licenses (y/N)?" prompt
$process.StandardInput.WriteLine("y")
Start-Sleep -Seconds 2

# Send y for each individual license (there can be up to 10)
for ($i = 0; $i -lt 15; $i++) {
    $process.StandardInput.WriteLine("y")
    Start-Sleep -Milliseconds 800
}

$process.StandardInput.Flush()
$process.StandardInput.Close()
$process.WaitForExit(60000)
Write-Host "Process exited with code: $($process.ExitCode)"
