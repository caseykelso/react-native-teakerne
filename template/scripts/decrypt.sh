#!/usr/bin/env bash
filename=".secretfiles"

# Check if MOBILE_KEY env variable exist and use it instead of input prompt.
if [[ -z "${MOBILE_KEY}" ]]
then
    echo "READ PROMPT"
    read -p "Enter the Decryption Key:" -s ENC_KEY  
else
    ENC_KEY=$MOBILE_KEY
fi

echo "decrypting..."
while read -r line
do
    name="$line"
    echo "decrypting $name"
    openssl enc -md md5 -aes-256-cbc -d -a -k $ENC_KEY -in $name.encrypted -out $name || rm $name
done < "$filename"
echo "DONE"

if [[ ! -f android/gradle.properties ]] ; then
	echo "decryption failed"
	exit 1
fi
