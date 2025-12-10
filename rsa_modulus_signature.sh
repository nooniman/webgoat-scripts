#!/bin/bash

# Create temporary file for the private key
cat > /tmp/private_key.pem << 'EOF'
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCHIgLwqxjFnpCjosx1FSP3I7AyYMGPW5Fuc5Tx+Tz0oyrVg/ZGuCTVVXglYq2TuGWyI/6m3IrmrEpr7CsWyZWMdhtuBJYE0RV/s5n/TxukQAB3LUO5OlI0QQhpGCNseax9k9IWizd/dLRRjmP7Irbttkd6B50VxHPtURmHivXMrKAt9ftmq2ZgtPrEQRQD3gsdunsvoH43Xu52oP1Ju4emxH0sV0JClx3cZcjQIfGzmj8AGlCF3berRFkAZfMZJI8UoBy438LwxDjsVaV/pS/rKQQs2eY/Wm2zVC/ldyYDnnp6DuPsKhhJ+bkHraf2Rsaghep2xRwXPHaVkh2X9YJ7AgERAoIBAAGW/QXX2SN0UAHs1TqZ2UUqlaY9X6RSZRlkv35UP/bUvj6/Sy4CKpkZGYHyGiLeBzhOurarQOGVmnm9ggNHpGUKbL8JFtjnWpsaNQMA7kEt7e9U3KfTgnkV2PItdeAlkpgQzEKGJ85Mqse8Z5OE7RHa/dRCWTBxvxri1iK5WjuhoyUkqrukKNPoMsOaNFdFe8jLdvTiWxNnC5R7CQhFKp+w3KbNEA31AbwWQZunzfCkyKh0dMKbn0Em3Pel4j7mnXsn/Fv7j0xcShOfdo7fsN/K0h6pjKwyz0L1g3N12InZIxeO9j0EX+U+h0FoUkH+PciYsmAlYHnT4JLDKjtPVGkCgYEArcl+wzvJg1svEY5jNS80tsttSRBUZOR6v66Ee5Wtzr1pDe+6i9FIsUGo+MN0AvPmxZR6FKVg8ww4wJlx99O+HoOXBi7jTncI99+bZiQucBZsGmdK+gqDd+GPSP9w8v8WHrd9vxAyahvrNQ1VNP04Ga0Tr60bM0CaJFA0PvJf13UCgYEAxw9Kh91gVKltDkOqfdqXOqa+stAj2+GtVntCgfUWkeOiK9qGYc702SdZB132jdj82Xz1d0LQ4/0kOizf3GLUJqzCS/914B8WqIjH4esxBYZlJZdDNwf4JJZAQY/lTT9vtPAZYpmD1xBLm0K1Iw+kKVi/AN1A4GNIwYqQ2PQ+pC8CgYAo5B3TlZjTnPwEIYDBOEijeyjF5bmBJrN4ZUxZUGUhlfqZ3g3Gi5iiLZEreUh5KlRquYYi+bx1bEmWurFnfR2s06sQg4DHKxErQ6wYCINlquxCcqg61UwcNRKnw6IbDtgHOju0fEgY94KjEjIqle8VGapHdAZmaY2uMP07/MtBwQKBgQCAzaiyQ/MJms4YSebJ58tEEYpzs9r3sCTdmwzqraUxOPB2upMwOp5uZMEi4nJbyKObyVOJZ3gbDTWPDfpDTwG+rAVAO+LcUFn0lL2SLsVd7Yy9+HbJQWRT6MAqbCr1v6KiQQFd6tzWc/SvwcCAGS38otXxgBrri4luLHvXrRl5SwKBgQCKqyIXpHgs1UHuohB1KdAYAUxSxzwM84oAieUgCToDhyDNahZbzucJ23U6NaUQgETiij2+zfMTRrCNf95+zs1NS1Ub784It/u6sckuvqwLlNWpSMcwuX2+Wjq1+t0zLvacjtNWudY7tTuGuNBC25754jnGWU2JLl6qW0qPteywag==
-----END PRIVATE KEY-----
EOF

echo "=== Extracting Modulus from Private Key ==="
echo

# Extract the modulus in hex format
modulus=$(openssl rsa -in /tmp/private_key.pem -noout -modulus | cut -d'=' -f2)

echo "Modulus (hex):"
echo "$modulus"
echo

# Create a file with the modulus for signing
echo -n "$modulus" > /tmp/modulus.txt

echo "=== Creating Signature ==="
echo

# Sign the modulus using SHA256
signature=$(openssl dgst -sha256 -sign /tmp/private_key.pem /tmp/modulus.txt | openssl base64 -A)

echo "Signature (base64):"
echo "$signature"
echo

# Cleanup
rm /tmp/private_key.pem /tmp/modulus.txt

echo "Done!"
