#!/usr/bin/env bash

filename=".secretfiles"
echo "Enter the Encryption Key:"
read -s ENC_KEY
echo "encrypting..."
while read -r line
do
    name="$line"
    echo "encrypting $name"
    openssl enc -md md5 -aes-256-cbc -a -k $ENC_KEY -in $name -out $name.encrypted || echo "cannot encrypt $name"
done < "$filename"
echo "DONE"
