# Step 1: Create the .ssh directory if it doesn't exist
$sshDir = "$HOME\.ssh"
if (!(Test-Path $sshDir)) {
    mkdir $sshDir
}

# Step 2: Define the SSH config content
$sshConfig = @"
# GitHub config for rtttel@gmail.com
Host github-email3
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_email3
    IdentitiesOnly yes

# GitHub config for email1
Host github-email1
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_email1
    IdentitiesOnly yes

# GitLab config
Host gitlab
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_rsa_email4
    IdentitiesOnly yes

# GitHub config for pouadjeub
Host github-pouadjeub
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_email5
    IdentitiesOnly yes

# Default GitHub config (belvip)
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
"@

# Step 3: Create or overwrite the config file
$sshConfigPath = "$sshDir\config"
$sshConfig | Out-File -FilePath $sshConfigPath -Encoding utf8 -Force

# Confirm result
Write-Output "SSH config file created at: $sshConfigPath"
