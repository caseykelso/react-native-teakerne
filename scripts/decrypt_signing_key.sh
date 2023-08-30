#!/usr/bin/env bash
filename=".signingfiles"

# Check if SIGNING_KEY env variable exist and use it instead of input prompt.
if [[ -z "${SIGNING_KEY}" ]]
then
    echo "READ PROMPT"
    read -p "Enter the Decryption Key:" -s ENC_KEY  
else
    ENC_KEY=$SIGNING_KEY
fi

echo "decrypting..."
while read -r line
do
    name="$line"
    echo "decrypting $name"
    openssl aes-256-cbc -d -a -pbkdf2 -k $ENC_KEY -in $name.encrypted -out $name || rm $name
done < "$filename"
echo "DONE"

if [[ ! -f keystore.jks ]] ; then
	echo "decryption failed"
	exit 1
fi
