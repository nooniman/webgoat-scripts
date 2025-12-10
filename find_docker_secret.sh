#!/bin/bash

# Docker Container Secret Finder
# This script helps find secrets in the webgoat/assignments:findthesecret container

echo "=== Starting Docker Container ==="
echo

# Start the container and capture the container ID
CONTAINER_ID=$(docker run -d webgoat/assignments:findthesecret)
echo "Container ID: $CONTAINER_ID"
echo

# Wait a moment for container to fully start
sleep 2

echo "=== Searching for password file in /root ==="
echo

# List files in /root directory
echo "Files in /root:"
docker exec $CONTAINER_ID ls -la /root
echo

echo "=== Looking for password/secret files ==="
echo

# Try to find any password-related files
echo "Files found in /root:"
docker exec $CONTAINER_ID find /root -type f 2>/dev/null
echo

echo "=== Checking common secret file names ==="
echo

# Check for common secret file names
COMMON_NAMES=("password" "secret" "default_secret" ".secret" "passwd" "password.txt" "secret.txt")
SECRET_FILE=""

for name in "${COMMON_NAMES[@]}"; do
    if docker exec $CONTAINER_ID test -f "/root/$name" 2>/dev/null; then
        echo "Found: /root/$name"
        echo "Content:"
        docker exec $CONTAINER_ID cat "/root/$name"
        echo
        SECRET_FILE="/root/$name"
        break
    fi
done

echo
echo "=== Attempting to read all files in /root ==="
echo

# Get all files and try to read them
docker exec $CONTAINER_ID find /root -type f 2>/dev/null | while read -r file; do
    if [ -n "$file" ]; then
        echo "File: $file"
        echo "Content:"
        docker exec $CONTAINER_ID cat "$file" 2>/dev/null
        echo
    fi
done

echo "=== Decrypting Message ==="
echo

ENCRYPTED_MESSAGE="U2FsdGVkX199jgh5oANElFdtCxIEvdEvciLi+v+5loE+VCuy6Ii0b+5byb5DXp32RPmT02Ek1pf55ctQN+DHbwCPiVRfFQamDmbHBUpD7as="

echo "If you found the secret file, use it to decrypt:"
echo "docker exec $CONTAINER_ID bash -c \"echo '$ENCRYPTED_MESSAGE' | openssl enc -aes-256-cbc -d -a -kfile /root/[SECRET_FILE]\""
echo

# Try to decrypt with found file if we have one
if [ -n "$SECRET_FILE" ]; then
    echo "Attempting decryption with $SECRET_FILE..."
    DECRYPTED=$(docker exec $CONTAINER_ID bash -c "echo '$ENCRYPTED_MESSAGE' | openssl enc -aes-256-cbc -d -a -kfile $SECRET_FILE" 2>/dev/null)
    
    if [ -n "$DECRYPTED" ]; then
        echo
        echo "=== SUCCESS ==="
        echo "Decrypted message: $DECRYPTED"
        echo "Password file name: $(basename $SECRET_FILE)"
    fi
fi

echo
echo "=== Cleanup ==="
echo "To stop and remove the container, run:"
echo "docker stop $CONTAINER_ID && docker rm $CONTAINER_ID"
