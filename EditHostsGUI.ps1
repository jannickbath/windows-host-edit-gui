Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Hosts File Manager'
$form.Size = New-Object System.Drawing.Size(700,500)  # Increased form size
$form.StartPosition = 'CenterScreen'

# Main display area for hosts entries
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(20, 50)
$listBox.Size = New-Object System.Drawing.Size(640, 300)  # Increased size
$listBox.SelectionMode = 'MultiExtended'
$form.Controls.Add($listBox)

$label = New-Object System.Windows.Forms.Label
$label.Text = 'Current Hosts Entries:'
$label.Location = New-Object System.Drawing.Point(20, 30)
$label.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($label)

# Function to update the list box with the hosts file contents
function Update-HostsDisplay {
    $listBox.Items.Clear()
    $content = Get-Content "C:\Windows\System32\drivers\etc\hosts" -ErrorAction SilentlyContinue
    foreach ($line in $content) {
        if ($line -notmatch "^\s*#" -and $line -match "\S") {
            $listBox.Items.Add($line)
        }
    }
}

# IP address input
$ipLabel = New-Object System.Windows.Forms.Label
$ipLabel.Text = 'IP Address:'
$ipLabel.Location = New-Object System.Drawing.Point(20, 380)
$ipLabel.Size = New-Object System.Drawing.Size(80, 20)
$form.Controls.Add($ipLabel)

$ipTextBox = New-Object System.Windows.Forms.TextBox
$ipTextBox.Location = New-Object System.Drawing.Point(120, 380)
$ipTextBox.Size = New-Object System.Drawing.Size(140, 20)  # Increased size
$form.Controls.Add($ipTextBox)

# Domain name input
$domainLabel = New-Object System.Windows.Forms.Label
$domainLabel.Text = 'Domain Name:'
$domainLabel.Location = New-Object System.Drawing.Point(280, 380)
$domainLabel.Size = New-Object System.Drawing.Size(100, 20)  # Adjusted size
$form.Controls.Add($domainLabel)

$domainTextBox = New-Object System.Windows.Forms.TextBox
$domainTextBox.Location = New-Object System.Drawing.Point(400, 380)
$domainTextBox.Size = New-Object System.Drawing.Size(180, 20)  # Increased size
$form.Controls.Add($domainTextBox)

# Button to add a new entry
$addButton = New-Object System.Windows.Forms.Button
$addButton.Location = New-Object System.Drawing.Point(600, 380)
$addButton.Size = New-Object System.Drawing.Size(60, 20)
$addButton.Text = 'Add Entry'
$addButton.Add_Click({
    $ip = $ipTextBox.Text
    $domain = $domainTextBox.Text
    if ($ip -and $domain) {
        $entry = "$ip`t$domain"
        Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value $entry
        Update-HostsDisplay
        $ipTextBox.Clear()
        $domainTextBox.Clear()
    }
})
$form.Controls.Add($addButton)

# Button to remove selected entries
$removeButton = New-Object System.Windows.Forms.Button
$removeButton.Location = New-Object System.Drawing.Point(20, 420)
$removeButton.Size = New-Object System.Drawing.Size(120, 30)  # Increased size
$removeButton.Text = 'Remove Selected'
$removeButton.Add_Click({
    $selectedItems = $listBox.SelectedItems
    $content = Get-Content "C:\Windows\System32\drivers\etc\hosts"
    foreach ($item in $selectedItems) {
        $content = $content | Where-Object { $_ -ne $item }
    }
    $content | Set-Content "C:\Windows\System32\drivers\etc\hosts"
    Update-HostsDisplay
})
$form.Controls.Add($removeButton)

# Button to refresh the list
$refreshButton = New-Object System.Windows.Forms.Button
$refreshButton.Location = New-Object System.Drawing.Point(160, 420)
$refreshButton.Size = New-Object System.Drawing.Size(120, 30)  # Increased size
$refreshButton.Text = 'Refresh List'
$refreshButton.Add_Click({
    Update-HostsDisplay
})
$form.Controls.Add($refreshButton)

# Initial load of hosts file
Update-HostsDisplay

# Hide the PowerShell console window
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

$form.ShowDialog()
