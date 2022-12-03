# OpenPGP

## Creating a key
https://www.phildev.net/pgp/gpgkeygen.html

## Sending your key to a keyserver
```
gpg --send-keys 7C998A2D26C760E0
```

## Exporting and Importing keys
https://www.phildev.net/pgp/gpg_moving_keys.html
Export:
```
gpg --export-secret-keys -a keyid > my_private_key.asc
gpg --export -a keyid > my_public_key.asc
```
Import:
```
gpg --import my_private_key.asc
gpg --import my_public_key.asc
```

## Editing and trusting keys
TODO: When should you trust a key ultimately? https://www.phildev.net/pgp/gpgtrust.html
```
gpg --edit-key foo@bar.com
trust
```

## Importing, signing, and verifying GPG file
```
gpg --import <(curl https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc)
gpg -k
gpg --sign-key veracrypt@idrix.fr
gpg --verify veracrypt-1.24-Update7-Ubuntu-20.04-amd64.deb.sig veracrypt-1.24-Update7-Ubuntu-20.04-amd64.deb
```

## Search for a key
You can search for a key using an e-mail address or key ID on the default keyserver (which appears to be http://pgp.surf.nl:11371 for me on Arch Linux.)
```
gpg --search-key gmail@evanstucker.com
gpg --search-key 7C998A2D26C760E0
gpg --keyserver keyserver.ubuntu.com --search-key gmail@evanstucker.com
```

## Download a key
```
gpg --keyserver pgpkeys.mit.edu --recv-key 2D230C5F
```
