#!/usr/bin/env bash

filename=".signingfiles"
echo "Enter the Encryption Key:"
read -s ENC_KEY
echo "encrypting..."
while read -r line
do
    name="$line"
    echo "encrypting $name"
    openssl aes-256-cbc -a -salt -pbkdf2 -k $ENC_KEY -in $name -out $name.encrypted || echo "cannot encrypt $name"
done < "$filename"
echo "DONE"
