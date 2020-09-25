# Ionic Clevis Pin

This pin uses Ionic Machina to request an Ionic Policy controlled AES key by its keyid using the
machina cli.

## Dependencies
This pin requires the `clevis` package. This pin also requires the `machina` cli available
[here](https://dev.ionic.com/tools). If operating inside of a virtual machine it may be necessary
to install and run the [haveged tool](https://github.com/jirka-h/haveged) to seed sufficient entropy
for the `machina` cli.

## Installation
Copy `clevis-encrypt-ionic` and `clevis-decrypt-ionic` to `/usr/bin/` along side the other clevis
pins.

### Setup
Once `machina` is installed a persistor should be enrolled
[see here](https://dev.ionic.com/tools/machina/profile_enroll) for details.

## Usage
The Ionic keyid must be provided in the JSON configuration for the pin.
`clevis encrypt ionic '{"keyid":"<mykeyid>"}' < plain.txt > cyptotext.jwe`

Machina general options can be specified in JSON configuration field.
`{"keyid":"<mykeyid>","generaloptions":"-t <devicetype> -f <devicefilepath>"}`
This is required when using any persistor other than the default.

## Using Ionic Clevis Pin for luks-bind
To use this pin for luks binding the `clevis-luks` package is also required. Do not rely on the
default persistor for machina instead specify a persistor located on the boot volume.

### luks encrypt a device
`cryptsetup --verify-passphrase luksFormat <device>`
Enter a backup password.

### unlock the device
`cryptsetup luksOpen <device> example`

### format the device
`mkfs.ext4 /dev/mapper/example`

### create mount destination
`mkdir /EXAMPLE`

### mount the device
`mount /dev/mapper/example /EXAMPLE`

### create a key with machina
`machina key create`
Record the keyid.

### bind the luks device
`clevis luks bind -d <device> ionic '{"keyid":"<mykeyid>","generaloptions":"-t <devicetype> -f <devicefilepath>"}`

## Configure automounting
Use the [clevis-mount-helper project](https://github.com/IonicDev/clevis-mount-helper)
to configure automounting of luks encrypted devices.
