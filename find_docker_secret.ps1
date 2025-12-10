# Docker Container Secret Finder
# This script helps find secrets in the webgoat/assignments:findthesecret container

Write-Host "=== Starting Docker Container ===" -ForegroundColor Green
Write-Host

# Start the container and capture the container ID
$containerId = docker run -d webgoat/assignments:findthesecret
Write-Host "Container ID: $containerId" -ForegroundColor Cyan
Write-Host

# Wait a moment for container to fully start
Start-Sleep -Seconds 2

Write-Host "=== Searching for password file in /root ===" -ForegroundColor Green
Write-Host

# List files in /root directory
Write-Host "Files in /root:" -ForegroundColor Yellow
docker exec -u root $containerId ls -la /root

Write-Host ""
Write-Host "=== Looking for password/secret files ===" -ForegroundColor Green
Write-Host

# Try to find any password-related files
$passwordFile = docker exec -u root $containerId find /root -type f 2>$null

Write-Host "Files found in /root:" -ForegroundColor Yellow
$passwordFile

Write-Host ""
Write-Host "=== Checking common secret file names ===" -ForegroundColor Green
Write-Host

# Check for common secret file names
$commonNames = @("password", "secret", "default_secret", ".secret", "passwd", "password.txt", "secret.txt")

foreach ($name in $commonNames) {
    $result = docker exec -u root $containerId test -f "/root/$name" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Found: /root/$name" -ForegroundColor Green
        Write-Host "Content:" -ForegroundColor Yellow
        docker exec -u root $containerId cat "/root/$name"
        Write-Host ""
        
        $secretFile = "/root/$name"
        break
    }
}

Write-Host ""
Write-Host "=== Attempting to read all files in /root ===" -ForegroundColor Green
Write-Host

# Get all files and try to read them
$files = docker exec -u root $containerId find /root -type f 2>$null
foreach ($file in $files) {
    if ($file) {
        Write-Host "File: $file" -ForegroundColor Cyan
        $content = docker exec -u root $containerId cat $file 2>$null
        if ($content) {
            Write-Host "Content: $content" -ForegroundColor Yellow
        }
        Write-Host ""
    }
}

Write-Host "=== Decrypting Message ===" -ForegroundColor Green
Write-Host

$encryptedMessage = "U2FsdGVkX199jgh5oANElFdtCxIEvdEvciLi+v+5loE+VCuy6Ii0b+5byb5DXp32RPmT02Ek1pf55ctQN+DHbwCPiVRfFQamDmbHBUpD7as="

Write-Host "If you found the secret file, use it to decrypt:" -ForegroundColor Yellow
Write-Host "docker exec $containerId bash -c `"echo '$encryptedMessage' | openssl enc -aes-256-cbc -d -a -kfile /root/[SECRET_FILE]`""
Write-Host ""

# Try to decrypt with found file if we have one
if ($secretFile) {
    Write-Host "Attempting decryption with $secretFile..." -ForegroundColor Green
    $decrypted = docker exec -u root $containerId bash -c "echo '$encryptedMessage' | openssl enc -aes-256-cbc -d -a -kfile $secretFile" 2>$null
    
    if ($decrypted) {
        Write-Host ""
        Write-Host "=== SUCCESS ===" -ForegroundColor Green
        Write-Host "Decrypted message: $decrypted" -ForegroundColor Cyan
        Write-Host "Password file name: $(Split-Path $secretFile -Leaf)" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "=== Cleanup ===" -ForegroundColor Green
Write-Host "To stop and remove the container, run:" -ForegroundColor Yellow
Write-Host "docker stop $containerId; docker rm $containerId"
