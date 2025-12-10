#!/usr/bin/env python3

import subprocess
import sys
import time

def run_command(command, capture_output=True):
    """Run a shell command and return the output"""
    try:
        if capture_output:
            result = subprocess.run(command, shell=True, capture_output=True, text=True)
            return result.stdout.strip(), result.returncode
        else:
            subprocess.run(command, shell=True)
            return "", 0
    except Exception as e:
        print(f"Error running command: {e}")
        return "", 1

def main():
    print("=== Starting Docker Container ===")
    print()
    
    # Start the container and capture the container ID
    container_id, _ = run_command("docker run -d webgoat/assignments:findthesecret")
    print(f"Container ID: {container_id}")
    print()
    
    # Wait a moment for container to fully start
    time.sleep(2)
    
    print("=== Searching for password file in /root ===")
    print()
    
    # List files in /root directory
    print("Files in /root:")
    files_output, _ = run_command(f"docker exec {container_id} ls -la /root")
    print(files_output)
    print()
    
    print("=== Looking for password/secret files ===")
    print()
    
    # Try to find any password-related files
    print("Files found in /root:")
    find_output, _ = run_command(f"docker exec {container_id} find /root -type f 2>/dev/null")
    print(find_output)
    print()
    
    print("=== Checking common secret file names ===")
    print()
    
    # Check for common secret file names
    common_names = ["password", "secret", "default_secret", ".secret", "passwd", "password.txt", "secret.txt"]
    secret_file = None
    
    for name in common_names:
        _, exit_code = run_command(f"docker exec {container_id} test -f /root/{name}")
        if exit_code == 0:
            print(f"Found: /root/{name}")
            print("Content:")
            content, _ = run_command(f"docker exec {container_id} cat /root/{name}")
            print(content)
            print()
            secret_file = f"/root/{name}"
            break
    
    print()
    print("=== Attempting to read all files in /root ===")
    print()
    
    # Get all files and try to read them
    files, _ = run_command(f"docker exec {container_id} find /root -type f 2>/dev/null")
    for file_path in files.split('\n'):
        if file_path.strip():
            print(f"File: {file_path}")
            print("Content:")
            content, _ = run_command(f"docker exec {container_id} cat {file_path}")
            print(content)
            print()
            if not secret_file:
                secret_file = file_path
    
    print("=== Decrypting Message ===")
    print()
    
    encrypted_message = "U2FsdGVkX199jgh5oANElFdtCxIEvdEvciLi+v+5loE+VCuy6Ii0b+5byb5DXp32RPmT02Ek1pf55ctQN+DHbwCPiVRfFQamDmbHBUpD7as="
    
    print("If you found the secret file, use it to decrypt:")
    print(f'docker exec {container_id} bash -c "echo \'{encrypted_message}\' | openssl enc -aes-256-cbc -d -a -kfile /root/[SECRET_FILE]"')
    print()
    
    # Try to decrypt with found file if we have one
    if secret_file:
        print(f"Attempting decryption with {secret_file}...")
        decrypted, exit_code = run_command(
            f"docker exec {container_id} bash -c \"echo '{encrypted_message}' | openssl enc -aes-256-cbc -d -a -kfile {secret_file}\""
        )
        
        if exit_code == 0 and decrypted:
            print()
            print("=== SUCCESS ===")
            print(f"Decrypted message: {decrypted}")
            print(f"Password file name: {secret_file.split('/')[-1]}")
    
    print()
    print("=== Cleanup ===")
    print("To stop and remove the container, run:")
    print(f"docker stop {container_id} && docker rm {container_id}")

if __name__ == "__main__":
    main()
