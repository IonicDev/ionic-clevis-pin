#!/bin/sh

# create a new Ionic Key and retain its keyId
kc="machina $devicearg key create $attributes -s"
kid=$(eval "${kc}" | awk '/keyId/{gsub(/[",]/,"",$3);print $3}')

# fetch the created Ionic Key and extract its base64 encoded key bytes
kf="machina $devicearg key fetch -i $kid -s"
key64=$(eval "${kf}" | awk '/keyData/{gsub(/[",]/,"",$3);print $3}')
# remove trailing = from base64 key
key64=${key64%=}
# assemble the jwk
jwk="{\"alg\":\"A256GCM\",\"k\":\"$key64\",\"key_ops\":[\"encrypt\",\"decrypt\"],\"kty\":\"oct\"}"

#Create a skeleton that declares the pin, and creates a store.
jwe='{"protected":{"clevis":{"pin":"ionic","ionic":{}}}}'
# Populate the store with the values needed to recreate the jwk
jwe="$(jose fmt --json="$jwe" --get protected --get clevis --get ionic --quote "$devicearg" --set devicearg -UUUU --output=-)"
jwe="$(jose fmt --json="$jwe" --get protected --get clevis --get ionic --quote "$kid" --set kid -UUUU --output=-)"

#%# Almost there!
#%# Forward everything to `jose jwe enc` which does the encryption job -
#%# including reading the plaintext from stdin which gets replicated
#%# using `cat`.
( printf '%s' "$jwe$jwk" ; cat ) | exec jose jwe enc --input=- --key=- --detached=- --compact &>output.txt
